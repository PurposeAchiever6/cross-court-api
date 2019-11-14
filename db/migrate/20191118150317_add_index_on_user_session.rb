class AddIndexOnUserSession < ActiveRecord::Migration[6.0]
  def change
    add_index :user_sessions, %i[date user_id session_id], unique: true
  end
end
