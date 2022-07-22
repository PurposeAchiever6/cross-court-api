class AddProductCategoryToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :available_for, :integer, default: 0
  end
end
