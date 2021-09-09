class AddProductTypeToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :product_type, :integer, default: 0
    remove_column :products, :stripe_id
  end
end
