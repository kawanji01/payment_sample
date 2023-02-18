class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,]
  before_action :correct_user,   only: [:edit, :update, :payment_setting, :invoices]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find_param(params[:id])
    @subscriptions = @user.customer&.subscriptions
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      @user.send_activation_email
      flash[:success] = t('users.creating_account_succeeded')
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find_param(params[:id])
    @breadcrumb_hash = {t('users.my_page') => user_path(@user),
                        'アカウント設定' => ''}
  end

  def update
    @user = User.find_param(params[:id])
    if @user.update(user_params)
      flash[:success] = 'プロフィールを更新しました。'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find_param(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def payment_setting
    @subscriptions = @user&.customer&.subscriptions
    @customer = @user.customer
    @stripe_card = @customer&.stripe_card
    @breadcrumb_hash = {t('users.my_page') => user_path(@user),
                        'お支払い設定' => ''}
  end


  def invoices
    customer = @user.customer
    @invoices = Stripe::Invoice.list(customer: customer.stripe_customer_id)
    @breadcrumb_hash = {t('users.my_page') => user_path(@user),
                        'お支払い設定' => payment_setting_user_path(@user),
                        '領収書/請求書' => ''}
  end



  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :profile, :profile, :icon, :remove_icon,
                                 :password_confirmation)
  end

  # beforeアクション

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find_param(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end