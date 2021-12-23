class AddIndexToProductType < ActiveRecord::Migration[6.0]
  def change
    add_index :products, :product_type
  end
end
