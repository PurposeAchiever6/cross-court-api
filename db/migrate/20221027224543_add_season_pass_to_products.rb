class AddSeasonPassToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :season_pass, :boolean, default: false
  end
end
