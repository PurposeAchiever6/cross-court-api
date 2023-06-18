class RemovePersonalInfoFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :weight
    remove_column :users, :height
    remove_column :users, :competitive_basketball_activity
    remove_column :users, :current_basketball_activity
    remove_column :users, :position
    remove_column :users, :main_goal
    remove_column :users, :goals
  end
end
