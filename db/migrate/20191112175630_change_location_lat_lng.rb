class ChangeLocationLatLng < ActiveRecord::Migration[6.0]
  def change
    rename_column :locations, :latitude, :lat
    rename_column :locations, :longitude, :lng
  end
end
