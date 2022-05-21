class AddFreeSessionMilesRadiusToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :free_session_miles_radius, :decimal
  end
end
