class AddBioToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :bio, :string
    add_index :users, :is_coach
  end
end
