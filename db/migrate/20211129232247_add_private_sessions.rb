class AddPrivateSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :private_access, :boolean, default: false
    add_column :sessions, :is_private, :boolean, default: false

    add_index :users, :private_access
  end
end
