class AddReserveTeamToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :reserve_team, :boolean, default: false
  end
end
