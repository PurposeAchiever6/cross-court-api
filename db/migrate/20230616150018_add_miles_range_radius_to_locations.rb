class AddMilesRangeRadiusToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :miles_range_radius, :decimal
  end
end
