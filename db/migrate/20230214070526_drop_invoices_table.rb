class DropInvoicesTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :invoices
  end
end
