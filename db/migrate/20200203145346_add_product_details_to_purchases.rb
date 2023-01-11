class AddProductDetailsToPurchases < ActiveRecord::Migration[6.0]
  def change
    change_table :purchases, bulk: true do |t|
      t.integer :credits
      t.string :name
    end

    Purchase.includes(:product).find_each do |purchase|
      product = purchase.product
      credits = product&.credits || 0
      name = product&.name || 'Pack'
      purchase.update!(credits:, name:)
    end

    change_column_null :purchases, :credits, false
    change_column_null :purchases, :name, false
  end
end
