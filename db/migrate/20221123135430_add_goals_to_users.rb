class AddGoalsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :goals, :string, array: true
    add_column :users, :main_goal, :string
  end
end
