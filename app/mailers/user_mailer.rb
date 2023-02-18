class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)
  add_template_helper(UsersHelper)

  def account_activation(user_id, activation_token)
    @activation_token = activation_token
    @user = User.find(user_id)
    mail to: @user.email, from: '"Sample" <Sample@gmail.com>', subject: "#{@user.name}さま、ご登録が完了いたしました。"
  end



  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  # パスワードリセットについては、deliver_nowのみ利用可能。
  def password_reset(user)
    @user = user
    return if @user.blank?
    mail to: @user.email, from: '"Sample" <Sample@gmail.com>', subject: 'パスワードリセット'
  end
end
