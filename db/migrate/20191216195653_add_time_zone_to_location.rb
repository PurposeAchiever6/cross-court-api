class AddTimeZoneToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :time_zone, :string, null: false, default: 'America/Los_Angeles'
  end
end
