class CustomersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: %i[edit destroy update delete_confirmation]

  def create
    if current_user.customer.blank? && params[:stripeToken].present?
      begin
        Customer.create_customer(current_user, params[:stripeToken])
        flash[:success] = 'お支払い方法を登録しました。'
        redirect_to payment_setting_user_url(current_user)
      rescue Stripe::CardError => e
        flash[:danger] = "決済(stripe)でエラーが発生しました。#{e.message}"
        redirect_to payment_setting_user_url(current_user)
      rescue Stripe::InvalidRequestError => e
        flash[:danger] = "決済(stripe)でエラーが発生しました（InvalidRequestError）#{e.message}"
        redirect_to payment_setting_user_url(current_user)

        # Authentication with Stripe's API failed(maybe you changed API keys recently)
      rescue Stripe::AuthenticationError => e
        flash[:danger] = "決済(stripe)でエラーが発生しました（AuthenticationError）#{e.message}"
        redirect_to payment_setting_user_url(current_user)

        # Network communication with Stripe failed
      rescue Stripe::APIConnectionError => e
        flash[:danger] = "決済(stripe)でエラーが発生しました（APIConnectionError）#{e.message}"
        redirect_to payment_setting_user_url(current_user)

        # Display a very generic error to the user, and maybe send yourself an email
      rescue Stripe::StripeError => e
        flash[:danger] = "決済(stripe)でエラーが発生しました（StripeError）#{e.message}"
        redirect_to payment_setting_user_url(current_user)

        # stripe関連以外でエラーが起こった場合
      rescue StandardError => e
        flash[:danger] = "エラーが発生しました#{e.message}"
        redirect_to payment_setting_user_url(current_user)
      end
    else
      flash[:danger] = 'すでにお支払い方法が登録されています。'
      redirect_to payment_setting_user_url(current_user)
    end
  end

  def edit
    @title = 'お支払い方法の更新'
    @breadcrumb_hash =  { 'マイページ' => user_path(current_user),
                          'お支払い設定' => payment_setting_user_path(current_user),
                          @title => '' }
  end

  def update
    p params[:stripeToken]
    @customer.update_customer(params[:stripeToken])
    flash[:success] = 'お支払い情報を更新しました。'
    redirect_to payment_setting_user_url(current_user)
  rescue Stripe::CardError => e
    flash[:danger] = "決済(stripe)でエラーが発生しました。#{e.message}"
    redirect_to edit_customer_url(@customer)
  rescue Stripe::InvalidRequestError => e
    flash[:danger] = "決済(stripe)でエラーが発生しました（InvalidRequestError）#{e.message}"
    redirect_to edit_customer_url(@customer)

    # Authentication with Stripe's API failed(maybe you changed API keys recently)
  rescue Stripe::AuthenticationError => e
    flash[:danger] = "決済(stripe)でエラーが発生しました（AuthenticationError）#{e.message}"
    redirect_to edit_customer_url(@customer)

    # Network communication with Stripe failed
  rescue Stripe::APIConnectionError => e
    flash[:danger] = "決済(stripe)でエラーが発生しました（APIConnectionError）#{e.message}"
    redirect_to edit_customer_url(@customer)

    # Display a very generic error to the user, and maybe send yourself an email
  rescue Stripe::StripeError => e
    flash[:danger] = "決済(stripe)でエラーが発生しました（StripeError）#{e.message}"
    redirect_to edit_customer_url(@customer)

    # stripe関連以外でエラーが起こった場合
  rescue StandardError => e
    flash[:danger] = "エラーが発生しました#{e.message}"
    redirect_to edit_customer_url(@customer)
  end

  def delete_confirmation
    @user = @customer.user
    @title = 'お支払い方法を消去'
    @breadcrumb_hash = {t('users.my_page') => user_path(@user),
                        'お支払い設定' => payment_setting_user_path(@user),
                         @title => ''}
  end

  def destroy
    @customer.destroy
    flash[:success] = 'お支払い方法を消去しました。'
    redirect_to payment_setting_user_url(current_user)
  end

  # カードの期限切れや与信落ち、紛失届によって決済が失敗した場合に送られるメールにリンクされている
  # カードの更新ページ
  def fix_payment_method
    @user = current_user
    @customer = @user.customer
    if @customer.present?
      flash[:warning] = 'カード情報を更新してください。'
      redirect_to edit_customer_url(@customer)
    else
      redirect_to payment_setting_user_path(@user)
    end
  end

  private

  def correct_user
    @customer = Customer.find(params[:id])
    if @customer.user == current_user || @customer&.chapter&.user == current_user
      true
    else
      redirect_to root_url
    end
  end
end
