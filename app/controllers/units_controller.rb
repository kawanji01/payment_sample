class UnitsController < ApplicationController
  before_action :admin_user, only: %i[new create edit update]
  def new
    @plan = Plan.find(params[:plan_id])
    @unit = Unit.new(plan: @plan)
  end

  def edit
    @unit = Unit.find(params[:id])
  end

  def create
    @unit = Unit.new(unit_params)
    if @unit.save
      flash[:success] = 'Unit created'
      redirect_to plans_path
    else
      flash[:danger] = 'Creating Unit failed'
      render 'units/new'
    end
  end

  def update
    @unit = Unit.find(params[:id])
    if @unit.update(unit_params)
      flash[:success] = 'Unit updated'
      redirect_to plans_path
    else
      flash[:danger] = 'Update failed'
      render 'units/edit'
    end
  end

  private

  def unit_params
    # stripe_plan_idはparamsに含めない。
    params.require(:unit).permit(:stripe_price_id, :amount, :plan_id)
  end
end
