class CreateStoreItems < ActiveRecord::Migration[6.0]
  def change
    create_table :store_items do |t|
      t.string :name
      t.string :description
      t.decimal :price

      t.timestamps
    end
  end
end
