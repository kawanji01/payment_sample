class UnitPurchase < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  belongs_to :customer, optional: true

  def self.create_session(user:, unit:, locale:)
    return if user.blank? || unit.blank? || locale.blank?

    success_url = Rails.application.routes.url_helpers.root_url(locale: locale) + "/unit_purchases/success?unit_id=#{unit.id}&session_id={CHECKOUT_SESSION_ID}"
    cancel_url = Rails.application.routes.url_helpers.user_url(user, locale: locale)
    price = unit.stripe_price_id
    if (customer = user.customer)
      Stripe::Checkout::Session.create({
                                         customer: customer.stripe_customer_id,
                                         line_items: [{
                                                        price: price,
                                                        quantity: 1,
                                                      }],
                                         payment_method_types: [
                                           'card',
                                         ],
                                         mode: 'payment',
                                         locale: locale,
                                         success_url: success_url,
                                         cancel_url: cancel_url
                                       })
    else
      Stripe::Checkout::Session.create({
                                         customer_email: user.email,
                                         line_items: [{
                                                        price: price,
                                                        quantity: 1,
                                                      }],
                                         payment_method_types: [
                                           'card',
                                         ],
                                         mode: 'payment',
                                         locale: locale,
                                         success_url: success_url,
                                         cancel_url: cancel_url,
                                       })
    end
  end

  def self.create_with_session(user:, unit:, customer:, session:)
    UnitPurchase.create!(customer: customer,
                         unit: unit,
                         user: user,
                         stripe_payment_intent_id: session['payment_intent'],)
  end

  def stripe_payment_intent
    Stripe::PaymentIntent.retrieve(
      self.stripe_payment_intent_id,
      )
  end

end
