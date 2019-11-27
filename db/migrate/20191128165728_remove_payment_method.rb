class RemovePaymentMethod < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :payment_method, :string
  end
end
