class CreateRefereeSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :referee_sessions do |t|
      t.references :user, null: false, index: true
      t.references :session, null: false, index: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :referee_sessions, %i[user_id session_id date], unique: true
  end
end
