class AddExtraDetailsToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :theme_title, :string
    add_column :sessions, :theme_subheading, :string
    add_column :sessions, :theme_sweat_level, :integer
    add_column :sessions, :theme_description, :text
  end
end
