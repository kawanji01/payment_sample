class UnitPurchasesController < ApplicationController
  before_action :logged_in_user

  def checkout
    @subscription = Subscription.find(params[:subscription_id])
    @plan = @subscription.plan
    if @plan.blank?
      flash[:danger] = 'プランが存在しないか、無効なプランです。'
      redirect_to root_url
    end
    @unit = @plan.unit
    if @unit.blank?
      flash[:danger] = 'ユニットが存在しないか、無効なユニットです。'
      redirect_to root_url
    end
    @session = UnitPurchase.create_session(user: current_user, unit: @unit, locale: @locale)
    if @session.blank?
      flash[:danger] = 'セッションがありません。'
      redirect_to root_url
    end
  end

  def success
    @unit = Unit.find(params[:unit_id])
    if @unit.blank? || params[:session_id].blank?
      flash[:danger] = '決済できませんでした。'
      redirect_to users_url(current_user)
    end
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @customer = Customer.create_or_update_with_session(user: current_user, session: session)
    @unit_purchase = UnitPurchase.create_with_session(user: current_user, unit: @unit,
                                                      customer: @customer, session: session)
    subscription = current_user.subscriptions.find_by(plan: @unit.plan)
    # 決済完了のメールの送信
    # PaymentMailer.make_subscription(@subscription.id).deliver_now
    flash[:success] = 'ご登録が完了いたしました。誠にありがとうございます！'
    redirect_to edit_subscription_path(subscription)
  end
end
