class AddScoutingToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :scouting, :boolean, default: :false
  end
end
