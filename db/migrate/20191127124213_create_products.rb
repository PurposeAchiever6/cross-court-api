class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :stripe_id, null: false
      t.integer :credits, null: false, default: 0
      t.timestamps
    end
  end
end
