class AddAttributesToProducts < ActiveRecord::Migration[6.0]
  def change
    change_table :products, bulk: true do |t|
      t.decimal :price, precision: 4, scale: 2, null: false, default: 0
      t.text :description
    end
  end
end
