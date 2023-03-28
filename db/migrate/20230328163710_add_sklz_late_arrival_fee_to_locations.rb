class AddSklzLateArrivalFeeToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :sklz_late_arrival_fee, :integer, default: 0
  end
end
