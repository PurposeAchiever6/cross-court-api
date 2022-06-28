class ChangePayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :last_4, :string
    add_column :payments, :stripe_id, :string
    add_column :payments, :status, :integer, default: 0
    add_column :payments, :error_message, :string
    add_column :payments, :cc_cash, :decimal, precision: 10, scale: 2, default: 0

    rename_column :payments, :price, :amount
    rename_column :payments, :name, :description

    remove_column :payments, :credits, :string
  end
end
