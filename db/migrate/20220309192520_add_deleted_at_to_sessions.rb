class AddDeletedAtToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :deleted_at, :datetime
    add_index :sessions, :deleted_at
  end
end
