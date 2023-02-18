class Subscription < ApplicationRecord
  belongs_to :plan
  belongs_to :customer
  belongs_to :user, optional: true
  # prepend ref: https://tech.actindi.net/2016/01/07/3661113852
  before_destroy :delete_stripe_subscription, prepend: true


  # セッション生成
  def self.create_session(user:, plan:, locale:)
    return if user.blank? || plan.blank? || locale.blank?

    success_url = Rails.application.routes.url_helpers.root_url(locale: locale) + "/subscriptions/success?plan_number=#{plan.reference_number}&session_id={CHECKOUT_SESSION_ID}"
    cancel_url = Rails.application.routes.url_helpers.user_url(user, locale: locale)
    # すでに一度トライアルを経験している場合にはnil
    trial_period_days = user.trial_used ? nil : plan.trial_period_days_count
    if (customer = user.customer)
      Stripe::Checkout::Session.create({
                                         customer: customer.stripe_customer_id,
                                         line_items: [{
                                                        price: plan.stripe_price_id,
                                                        quantity: 1,
                                                      }],
                                         payment_method_types: [
                                           'card',
                                         ],
                                         mode: 'subscription',
                                         subscription_data: { trial_period_days: trial_period_days },
                                         locale: locale,
                                         success_url: success_url,
                                         cancel_url: cancel_url,
                                       })
    else
      Stripe::Checkout::Session.create({
                                         customer_email: user.email,
                                         line_items: [{
                                                        price: plan.stripe_price_id,
                                                        quantity: 1,
                                                      }],
                                         payment_method_types: [
                                           'card',
                                         ],
                                         mode: 'subscription',
                                         subscription_data: { trial_period_days: trial_period_days },
                                         locale: locale,
                                         success_url: success_url,
                                         cancel_url: cancel_url,
                                       })
    end
  end

  def self.create_with_session(user:, plan:, customer:, session:)
    annual = plan.interval == 'year'
    stripe_subscription = Stripe::Subscription.retrieve(
      session.subscription,
    )
    Subscription.create!(customer: customer,
                         plan: plan,
                         user: user,
                         stripe_subscription_id: session.subscription,
                         trial_start: stripe_subscription.trial_start,
                         trial_end: stripe_subscription.trial_end,
                         annual: annual)
  end


  def stripe_subscription
    Stripe::Subscription.retrieve(
      self.stripe_subscription_id,
    )
  end

  # サブスクリプションをキャンセル
  def cancel_subscription
    stripe_subscription = Stripe::Subscription.cancel(
      self.stripe_subscription_id,
    )
    update(canceled: true,
           period_end: stripe_subscription['current_period_end'])
  end

  # 従量課金のquantityを増減させたり、確認するには、subscription_item（si）が必要。
  # ref: https://qiita.com/_akira19/items/4688ebaf87b44462baf2
  def stripe_subscription_item_list
    subscription_item_list = Stripe::SubscriptionItem.list(
      subscription: self.stripe_subscription_id
    )
    subscription_item_list
  end

  # si_xxxを取得する
  def stripe_subscription_item_ids
    list = self.stripe_subscription_item_list
    data_ary = list.data
    data_ary&.map { |data| data.id }
  end

  def stripe_subscription_item
    ids = self.stripe_subscription_item_ids
    Stripe::SubscriptionItem.retrieve(
      ids.first,
    )
  end

  # Schoolプランの従量課金の量を更新する ref: https://stripe.com/docs/billing/subscriptions/usage-based?locale=ja-JP#report
  def update_quantity(stripe_si_id, usage_quantity)
    return if stripe_si_id.blank? || usage_quantity.blank?

    timestamp = Time.now.to_i
    # The idempotency key allows you to retry this usage record call if it fails.
    idempotency_key = SecureRandom.hex(8)

    begin
      Stripe::SubscriptionItem.create_usage_record(
        stripe_si_id,
        {
          quantity: usage_quantity,
          timestamp: timestamp,
          action: 'set'
        }, {
          idempotency_key: idempotency_key
        }
      )
    rescue Stripe::StripeError => e
      puts "Usage report failed for item #{stripe_si_id}:"
      puts "#{e.error.message} (idempotency key: #{idempotency_key})"
    end
  end

  # ユニット数を更新する
  def update_stripe_on_usage(units_count)
    ids = stripe_subscription_item_ids
    update_quantity(ids.first, units_count)
    # ref: https://qiita.com/_akira19/items/4688ebaf87b44462baf2
  end

  def trial_ended?
    return true if self.trial_end.blank?

    unix_time_now = Time.now.to_i
    self.trial_end < unix_time_now
  end

  def trial_start_time
    Time.at(self.trial_start)
  end

  def trial_end_time
    Time.at(self.trial_end)
  end

  # サブスクを契約した本人かを確認する
  def correct_user?(user)
    self.customer.user == user
  end

  def self.find_by_webhook(event)
    subscription = event.data.object
    self.find_by(stripe_subscription_id: subscription['id'])
  end

  def self.find_by_sub_schedule(event)
    subscription_schedule = event.data.object
    self.find_by(stripe_subscription_id: subscription_schedule['subscription'])
  end

  def self.find_user_by_webhook(event)
    self.find_by_webhook(event)&.user rescue nil
  end

  def period_end_day
    Time.at(self.period_end).strftime("%Y/%m/%d")
  end

  # 有効期限の切れたサブスクを削除する。
  def self.destroy_expired_subscriptions
    unit_time_now = Time.current.to_i
    Subscription.where("canceled = ? AND period_end < ?", true, unit_time_now).destroy_all
  end

  private

  def delete_stripe_subscription
    # Stripeの課金データを削除
    begin
      Stripe::Subscription&.delete(stripe_subscription_id)
    rescue StandardError
      nil
    end
  end
end
