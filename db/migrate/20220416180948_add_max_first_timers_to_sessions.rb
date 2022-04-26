class AddMaxFirstTimersToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :max_first_timers, :integer
  end
end
