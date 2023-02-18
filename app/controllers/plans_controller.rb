class PlansController < ApplicationController

  # dependent: :destroyの前に、before_destroyをおく。
  before_action :admin_user, only: %i[index new create edit update destroy]

  def index
    @plans = Plan.includes(:unit).order(reference_number: :asc)
  end

  def new
    @plan = Plan.new
  end

  def create
    @plan = Plan.new(plan_params)
    @plan.set_attributes_by_stripe_id
    if @plan.save
      flash[:success] = 'Plan created'
      redirect_to plans_path
    else
      flash[:danger] = 'Creating Plan failed'
      render 'plans/new'
    end
  end

  def edit
    @plan = Plan.find(params[:id])
  end

  def update
    @plan = Plan.find(params[:id])
    @plan.set_attributes_by_stripe_id
    if @plan.update(plan_params)
      flash[:success] = 'Plan updated'
      redirect_to plans_path
    else
      flash[:danger] = 'Update failed'
      render 'plans/edit'
    end
  end

  def destroy
    #  @plan = Plan.find(params[:id])
    #  @stripe_plan_id = @plan.stripe_plan_id
    #  @plan.destroy
    #  flash[:danger] = 'プランを削除しました。'
    #  redirect_to plans_url
  end


  def introduction

  end



  private

  def plan_params
    # stripe_plan_idはparamsに含めない。
    params.require(:plan).permit(:stripe_price_id, :nickname, :amount, :trial_period_days, :reference_number)
  end
end
