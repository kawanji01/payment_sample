class CreateUnitPurchases < ActiveRecord::Migration[6.0]
  def change
    create_table :unit_purchases do |t|
      t.references :customer
      t.references :unit
      t.references :user
      t.string :stripe_payment_intent_id
      t.timestamps
    end
  end
end
