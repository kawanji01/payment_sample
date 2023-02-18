class AddCancelledToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :canceled, :boolean, default: false, null: false
  end
end
