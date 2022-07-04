class ChangePurchasesToPayments < ActiveRecord::Migration[6.0]
  def change
    rename_table :purchases, :payments
  end
end
