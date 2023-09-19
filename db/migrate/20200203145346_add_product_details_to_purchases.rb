class AddProductDetailsToPurchases < ActiveRecord::Migration[6.0]
  def change
    change_table :purchases, bulk: true do |t|
      t.integer :credits
      t.string :name
    end

    change_column_null :purchases, :credits, false
    change_column_null :purchases, :name, false
  end
end
