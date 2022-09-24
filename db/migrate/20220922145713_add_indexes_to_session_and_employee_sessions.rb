class AddIndexesToSessionAndEmployeeSessions < ActiveRecord::Migration[6.0]
  def change
    add_index :sessions, :start_time
    add_index :employee_sessions, :type
  end
end
