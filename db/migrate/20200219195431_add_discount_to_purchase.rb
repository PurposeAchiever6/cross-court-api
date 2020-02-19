class AddDiscountToPurchase < ActiveRecord::Migration[6.0]
  def change
    add_column :purchases, :discount, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
