class CreateUserSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, index: true
      t.references :session, null: false, index: true
      t.integer :state, null: false, default: 0

      t.timestamps
    end

    add_index :user_sessions, %i[user_id session_id], unique: true
  end
end
