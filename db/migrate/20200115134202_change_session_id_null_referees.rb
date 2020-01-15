class ChangeSessionIdNullReferees < ActiveRecord::Migration[6.0]
  def change
    change_column_null :referee_sessions, :session_id, true
    change_column_null :sem_sessions, :session_id, true
  end
end
