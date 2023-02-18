class PaymentMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  add_template_helper(UsersHelper)



  def make_subscription(subscription_id)
    @subscription = Subscription.find(subscription_id)
    @plan = @subscription.plan
    @user = @subscription.user
    mail(
      to: @user.email,
      from: '"Sample" <Sample@gmail.com>',
      subject: "#{@plan.nickname}に登録完了しました！"
    )
  end


  def cancel_subscription(subscription_id)
    @subscription = Subscription.find(subscription_id)
    @plan = @subscription.plan
    @user         = @subscription.user
    mail(
      to: @user.email,
      from: '"Sample" <Sample@gmail.com>',
      subject: "#{@plan.nickname}のご解約を完了いたしました。"
    )
  end





end
