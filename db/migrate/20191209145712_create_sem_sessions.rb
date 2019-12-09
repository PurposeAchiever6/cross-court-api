class CreateSemSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sem_sessions do |t|
      t.references :user, null: false, index: true
      t.references :session, null: false, index: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :sem_sessions, %i[user_id session_id date], unique: true
  end
end
