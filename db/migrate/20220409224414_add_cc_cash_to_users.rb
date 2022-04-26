class AddCcCashToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :cc_cash, :decimal, default: 0
  end
end
