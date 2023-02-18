class CreateInvoices < ActiveRecord::Migration[6.0]
  def change
    create_table :invoices do |t|
      t.references :user
      t.string :stripe_invoice_id
      t.string :stripe_subscription_id
      t.string :plan_name
      t.timestamps
    end
  end
end
