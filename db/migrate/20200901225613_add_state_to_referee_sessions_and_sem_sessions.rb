class AddStateToRefereeSessionsAndSemSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :referee_sessions, :state, :integer, null: false, default: 0
    add_column :sem_sessions, :state, :integer, null: false, default: 0
  end
end
