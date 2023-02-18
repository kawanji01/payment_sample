class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans do |t|
      t.string :stripe_product_id
      t.string :stripe_price_id
      t.string :nickname
      t.string :currency
      t.string :interval
      t.integer :amount
      t.integer :additional_fee
      t.integer :trial_period_days
      t.string  :usage_type
      t.integer :reference_number
      t.timestamps
    end
    add_index :plans, :reference_number
  end
end
