class AddFlaggedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :flagged, :boolean, default: false
  end
end
