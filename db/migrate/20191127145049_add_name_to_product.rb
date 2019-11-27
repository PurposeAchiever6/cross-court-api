class AddNameToProduct < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :name, :string, null: false, default: ''
    add_index :products, :stripe_id, unique: true
  end
end
