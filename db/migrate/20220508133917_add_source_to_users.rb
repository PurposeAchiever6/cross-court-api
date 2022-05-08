class AddSourceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :source, :string
    add_index :users, :source
  end
end
