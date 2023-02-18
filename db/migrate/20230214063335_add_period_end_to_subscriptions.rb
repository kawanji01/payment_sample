class AddPeriodEndToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :period_end, :integer
    remove_column :plans, :unit_amount, :integer
    remove_column :plans, :stripe_product_id, :string
    remove_column :users, :premium, :boolean
    add_index :subscriptions, [:user_id, :plan_id], unique: true
  end
end
