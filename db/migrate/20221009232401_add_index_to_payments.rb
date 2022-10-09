class AddIndexToPayments < ActiveRecord::Migration[6.0]
  def change
    add_index :payments, :status
  end
end
