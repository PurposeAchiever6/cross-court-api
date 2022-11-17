class AddMembersOnlyToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :members_only, :boolean, default: false
  end
end
