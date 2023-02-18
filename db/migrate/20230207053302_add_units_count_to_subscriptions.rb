class AddUnitsCountToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :units_count, :integer, default: 0, null: false
    rename_column :plans, :additional_fee, :unit_amount
    add_column :users, :premium, :boolean, default: false, null: false
  end
end
