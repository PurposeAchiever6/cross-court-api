class ReplaceAndRemoveSourceFromUsers < ActiveRecord::Migration[7.0]
  def up
    User.find_each { |user| user.update_column(:utm_source, user.source) }

    remove_column :users, :source
  end

  def down
    add_column :users, :source, :string
    add_index :users, :source

    User.find_each { |user| user.update_column(:source, user.utm_source) }
  end
end
