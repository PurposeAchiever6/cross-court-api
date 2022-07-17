class AddMaxCapacityToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :max_capacity, :integer, default: 15
  end
end
