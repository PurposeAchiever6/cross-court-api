class AddDropInExpirationDateToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :drop_in_expiration_date, :date
    add_index :users, :drop_in_expiration_date
    add_index :users, :free_session_expiration_date
  end
end
