class AddPersonalInformationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :weight, :integer
    add_column :users, :height, :integer
    add_column :users, :competitive_basketball_activity, :string
    add_column :users, :current_basketball_activity, :string
    add_column :users, :position, :string
  end
end
