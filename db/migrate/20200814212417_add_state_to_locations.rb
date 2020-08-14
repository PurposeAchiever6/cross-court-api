class AddStateToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :state, :string, default: "CA"
  end
end
