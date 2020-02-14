class AddOrderNumberToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :order_number, :integer, null: false, default: 0
  end
end
