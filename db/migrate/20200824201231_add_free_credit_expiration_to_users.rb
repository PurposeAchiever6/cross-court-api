class AddFreeCreditExpirationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :free_session_expiration_date, :date
  end
end
