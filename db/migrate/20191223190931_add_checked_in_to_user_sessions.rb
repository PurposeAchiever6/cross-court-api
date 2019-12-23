class AddCheckedInToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :checked_in, :bool, null: false, default: false
  end
end
