class AddLabelToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :label, :string
  end
end
