class AddScoutingCreditsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :scouting_credits, :integer, default: 0
  end
end
