class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :customer
      t.references :plan
      t.references :user
      t.string :stripe_subscription_id
      t.integer :trial_start
      t.integer :trial_end
      t.boolean :annual, default: false, null: false
      t.timestamps
    end
  end
end
