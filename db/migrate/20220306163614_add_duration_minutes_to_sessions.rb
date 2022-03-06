class AddDurationMinutesToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :duration_minutes, :integer, default: 60
  end
end
