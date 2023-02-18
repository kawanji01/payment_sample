desc 'This task is called by the Heroku scheduler add-on'

desc '有効期限の切れたサブスクを削除する'
task destroy_expired_subscriptions: :environment do
  Subscription.destroy_expired_subscriptions
end