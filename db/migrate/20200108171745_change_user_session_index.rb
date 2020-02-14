class ChangeUserSessionIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :user_sessions, name: 'index_user_sessions_on_date_and_user_id_and_session_id'

    add_index :user_sessions, %i[date user_id state session_id],
              name: 'index_user_sessions_on_date_user_id_state_session_id',
              unique: true
  end
end
