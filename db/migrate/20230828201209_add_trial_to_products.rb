class AddTrialToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :trial, :boolean, default: false
  end
end
