class AddCommingSoonFlagToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :coming_soon, :boolean, default: false
  end
end
