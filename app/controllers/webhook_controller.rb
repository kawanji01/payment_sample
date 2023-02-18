class WebhookController < ApplicationController
  protect_from_forgery except: [:stripe, :revenue_cat]

  def stripe
    payload = request.body.read
    event = nil
    # STRIPE_SIGNING_SECRET
    endpoint_secret = ENV['STRIPE_ENDPOINT_SECRET']

    #begin
    #  event = Stripe::Event.construct_from(
    #   JSON.parse(payload, symbolize_names: true)
    #  )
    #rescue JSON::ParserError => e
    # Invalid payload
    #  puts "⚠️  Webhook error while parsing basic request. #{e.message}"
    #  return
    #end
    # Check if webhook signing is configured.

    # Retrieve the event by verifying the signature using the raw body and secret.
    signature = request.env['HTTP_STRIPE_SIGNATURE']
    begin
      event = Stripe::Webhook.construct_event(
        payload, signature, endpoint_secret
      )
    rescue Stripe::SignatureVerificationError => e
      puts "⚠️  Webhook signature verification failed. #{e.message}"
      # status 400
    end

    # Handle the event
    case event.type
    when 'customer.created'
      @user = Customer.find_user_by_webhook(event)
    when 'customer.updated'
      @user = Customer.find_user_by_webhook(event)
    when 'customer.subscription.created'
      @user = Subscription.find_user_by_webhook(event)
    when 'customer.subscription.updated'
      @user = Subscription.find_user_by_webhook(event)
    when 'customer.subscription.deleted'
      # Stripe::Subscription.cancelされた場合に発火
      @user = Subscription.find_user_by_webhook(event)
    when 'customer.subscription.trial_will_end'
      @user = Subscription.find_user_by_webhook(event)
    when 'payment_intent.created'
      customer = Customer.find_by_payment_intent(event)
      @user = customer.user
    when 'payment_intent.payment_failed'
      customer = Customer.find_by_payment_intent(event)
      @user = customer.user
    when 'payment_intent.succeeded'
      customer = Customer.find_by_payment_intent(event)
      @user = customer.user
    when 'payment_method.attached'
      customer = Customer.find_by_payment_intent(event)
      @user = customer.user
    when 'subscription_schedule.aborted'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    when 'subscription_schedule.canceled'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    when 'subscription_schedule.completed'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    when 'subscription_schedule.created'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    when 'subscription_schedule.expiring'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    when 'subscription_schedule.released'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    when 'subscription_schedule.updated'
      subscription = Subscription.find_by_sub_schedule(event)
      @user = subscription.user
      subscription_schedule = event.data.object
    else
      puts "Unhandled event type: #{event.type}"
    end

    channel = "#stripe_webhook"
    type  = event.type
    content = "#{event.type} / NAME: #{@user&.name} / ID: #{@user&.id} / UID: #{@user&.public_uid} / MAIL: #{@user&.email}"
    notifier = Slack::Notifier.new(
      ENV['WEBHOOK_URL'],
      channel: channel,
      username: type,
      )
    a_ok_note = {
      title: type,
    }
    notifier.post text: content,
                  icon_url: DIQT_ICON,
                  attachments: [a_ok_note]
  end
end
