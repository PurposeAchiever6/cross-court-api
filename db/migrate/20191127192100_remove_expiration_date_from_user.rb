class RemoveExpirationDateFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :credit_expiration_date, :date
  end
end
