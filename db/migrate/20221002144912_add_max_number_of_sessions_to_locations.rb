class AddMaxNumberOfSessionsToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :max_sessions_booked_per_day, :integer
    add_column :locations, :max_skill_sessions_booked_per_day, :integer
  end
end
