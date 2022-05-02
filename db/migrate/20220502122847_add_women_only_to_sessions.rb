class AddWomenOnlyToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :women_only, :boolean, default: false
  end
end
