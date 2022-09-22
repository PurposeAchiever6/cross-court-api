class AddDefaultEmployeesToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :default_referee_id, :integer, null: true
    add_column :sessions, :default_sem_id, :integer, null: true
    add_column :sessions, :default_coach_id, :integer, null: true

    add_index :sessions, :default_referee_id
    add_index :sessions, :default_sem_id
    add_index :sessions, :default_coach_id
  end
end
