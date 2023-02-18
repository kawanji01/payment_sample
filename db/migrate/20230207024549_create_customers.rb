class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.references :user
      t.string :stripe_customer_id
      t.timestamps
    end
  end
end
