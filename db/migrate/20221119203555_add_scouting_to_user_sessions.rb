class AddScoutingToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :scouting, :boolean, default: false
  end
end
