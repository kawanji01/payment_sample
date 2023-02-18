class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :units do |t|
      t.references :plan
      t.integer :amount
      t.string :stripe_price_id
      t.timestamps
    end
  end
end
