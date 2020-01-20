class ChangePriceDecimalPurchases < ActiveRecord::Migration[6.0]
  def change
    change_column :purchases, :price, :decimal, precision: 10, scale: 2
  end
end
