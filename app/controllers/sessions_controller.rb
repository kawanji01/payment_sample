class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      else
        log_in user
        message  = "アカウントが有効化されていません。"
        message += "パスワードリセット機能が利用できるように、メールを確認して有効化リンクをクリックしてください。"
        flash[:warning] = message
        redirect_back_or user
      end
    else
      flash.now[:danger] = 'メールアドレスとパスワードが無効な組み合わせです。'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
