class CreatePurchases < ActiveRecord::Migration[6.0]
  def change
    create_table :purchases do |t|
      t.references :product, index: true
      t.references :user, index: true
      t.decimal :price, null: false, precision: 4, scale: 2

      t.timestamps
    end
  end
end
