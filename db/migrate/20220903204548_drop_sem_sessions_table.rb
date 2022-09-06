class DropSemSessionsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :sem_sessions do |t|
      t.references :user, null: false, index: true
      t.references :session, null: true, index: true
      t.date :date, null: false
      t.integer :state, null: false, default: 0

      t.timestamps

    end
  end
end
