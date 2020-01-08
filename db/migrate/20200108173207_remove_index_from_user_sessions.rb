class RemoveIndexFromUserSessions < ActiveRecord::Migration[6.0]
  def change
    remove_index :user_sessions, name: 'index_user_sessions_on_date_user_id_state_session_id'
  end
end
