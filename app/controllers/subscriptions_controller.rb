class SubscriptionsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user, only: [:index]
  before_action :correct_user, only: %i[destroy update show edit cancel]

  def index
    @subscriptions = Subscription.all
  end

  def checkout
    @plan = Plan.find_by(reference_number: params[:plan_number])
    if @plan.blank?
      flash[:danger] = '無効なプランです。'
      redirect_to root_url
    end
    @session = Subscription.create_session(user: current_user, plan: @plan, locale: @locale)
  end

  def success
    @plan = Plan.find_by(reference_number: params[:plan_number])
    if @plan.blank? || params[:session_id].blank?
      flash[:danger] = '決済できませんでした。'
      redirect_to users_url(current_user)
    end
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @customer = Customer.create_or_update_with_session(user: current_user, session: session)
    @subscription = Subscription.create_with_session(user: current_user, plan: @plan,
                                                     customer: @customer, session: session)
    # ユーザーをプレミアム会員にする。
    current_user.assign_attributes(trial_used: true)
    current_user.save(validate: false)
    # 決済完了のメールの送信
    PaymentMailer.make_subscription(@subscription.id).deliver_now
    flash[:success] = 'ご登録が完了いたしました。誠にありがとうございます！'
    redirect_to current_user
  end



  def edit
    @plan = @subscription.plan
    @stripe_subscription = @subscription.stripe_subscription
    @unit = @plan.unit
    @unit_purchases = current_user.unit_purchases.where(unit: @unit).order(created_at: :desc)
    @title = 'プラン設定'
    @user = @subscription.user
    @breadcrumb_hash = {t('users.my_page') => user_path(@user),
                        'お支払い設定' => payment_setting_user_path(@user),
                        'プラン設定' => ''}
  end

  # 追加授業の申し込み
  def update
    units_count = params[:subscription][:units_count].to_i
    if units_count.present?
      @subscription.update(units_count: units_count)
      @subscription.update_stripe_on_usage(units_count)
      flash[:success] = 'プランの更新を完了しました。'
      redirect_to current_user
    else
      flash[:success] = 'プランの更新に失敗しました。'
      redirect_to current_user
    end
  end

  def show
    @subscription = Subscription.find(params[:id])
    @chapter = @subscription.chapter
    @breadcrumb_hash = { 'マイページ' => user_path(current_user),
                         'お支払い設定' => payment_setting_user_path(current_user),
                         'ご解約' => '' }
  end

  def cancel
    @subscription.cancel_subscription
    PaymentMailer.cancel_subscription(@subscription.id).deliver_now
    flash[:success] = "プランを解約しました。"
    redirect_to edit_subscription_url(@subscription)
  end

  private

  def correct_user
    @subscription = Subscription.find(params[:id])
    if @subscription.correct_user?(current_user)
      true
    else
      redirect_to root_url
    end
  end
end
