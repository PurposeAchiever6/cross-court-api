class AddGoalToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :goal, :string
  end
end
