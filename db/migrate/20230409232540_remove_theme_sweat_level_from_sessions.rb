class RemoveThemeSweatLevelFromSessions < ActiveRecord::Migration[7.0]
  def change
    remove_column :sessions, :theme_sweat_level, :integer
  end
end
