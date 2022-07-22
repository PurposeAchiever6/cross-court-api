class AddInstagramUsernameToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :instagram_username, :string
  end
end
