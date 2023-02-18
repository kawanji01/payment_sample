class Customer < ApplicationRecord
  belongs_to :user, optional: true
  has_many :subscriptions, dependent: :destroy
  before_destroy :delete_stripe_customer, prepend: true

  # 引数のStripeToken（クライアント側で取得）を使って、引数のuserにcustomerを作成する。
  def self.create_customer(user, stripe_token)
    stripe_customer = Stripe::Customer.create(email: user.email,
                                              source: stripe_token)
    return nil if stripe_customer.blank?
    customer = Customer.new(stripe_customer_id: stripe_customer.id,
                            user_id: user.id,)
    customer.save!
  end

  def update_customer(stripe_token)
    customer = Stripe::Customer.update(self.stripe_customer_id,
                                       { source: stripe_token })
    update(stripe_customer_id: customer.id)
  end

  def retrieve_stripe_customer
    begin
      Stripe::Customer&.retrieve(self.stripe_customer_id)
    rescue StandardError
      nil
    end
  end

  # 決済に利用したカードのリスト
  # ref: https://stripe.com/docs/api/payment_methods/customer
  def stripe_cards
    Stripe::Customer.list_payment_methods(
      self.stripe_customer_id,
      { type: 'card' },
      )&.data rescue nil
  end

  # メインのカード情報
  def stripe_card
    stripe_cards&.first&.card
  end

  # チェックアウトの支払い成功後のsessionを利用してcustomerを作成or更新数r
  def self.create_or_update_with_session(user:, session:)
    # ユーザーが支払い情報を作成していなければ、作成する
    if (customer = user.customer)
      customer.update(stripe_customer_id: session.customer)
    else
      # stripe_customer = Stripe::Customer.retrieve(session.customer)
      customer = Customer.create(stripe_customer_id: session.customer,
                                 user: user)
    end
    customer
  end

  def self.find_by_webhook(event)
    customer = event.data.object
    self.find_by(stripe_customer_id: customer['id'])
  end

  def self.find_by_payment_intent(event)
    payment_intent = event.data.object
    self.find_by(stripe_customer_id: payment_intent['customer'])
  end

  def self.find_user_by_webhook(event)
    self.find_by_webhook(event)&.user rescue nil
  end

  private

  # Stipe側のデータも消し込む
  def delete_stripe_customer
    Stripe::Customer.delete(stripe_customer_id)
  rescue StandardError
    nil
  end
end
