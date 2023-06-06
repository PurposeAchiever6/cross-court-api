class AddUtmFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :utm_source, :string
    add_column :users, :utm_medium, :string
    add_column :users, :utm_campaign, :string
    add_column :users, :utm_term, :string
    add_column :users, :utm_content, :string

    add_index :users, :utm_source
    add_index :users, :utm_medium
    add_index :users, :utm_campaign
    add_index :users, :utm_term
    add_index :users, :utm_content
  end
end
