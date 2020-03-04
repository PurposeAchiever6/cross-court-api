class AddLevelToSession < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :level, :integer, null: false, default: 0
  end
end
