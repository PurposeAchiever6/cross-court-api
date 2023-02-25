class AddLateArrivalFeeToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :late_arrival_minutes, :integer, default: 10
    add_column :locations, :late_arrival_fee, :integer, default: 10
    add_column :locations, :allowed_late_arrivals, :integer, default: 2
  end
end
