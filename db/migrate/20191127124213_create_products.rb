class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :stripe_id, null: false, unique: true, index: true
      t.integer :credits, null: false, default: 0
      t.string :name, null: false
      t.timestamps
    end
  end
end
