class AddAmountRefundedToPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :amount_refunded, :decimal, precision: 10, scale: 2, default: 0
  end
end
