class AddFirstSessionToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :first_session, :boolean, default: false

    UserSession.free_sessions.update_all(first_session: true)
  end
end
