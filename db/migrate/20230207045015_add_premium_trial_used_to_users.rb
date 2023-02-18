class AddPremiumTrialUsedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :trial_used, :boolean, default: false, null: false
  end
end
