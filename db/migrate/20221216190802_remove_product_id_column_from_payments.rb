class RemoveProductIdColumnFromPayments < ActiveRecord::Migration[6.0]
  def change
    remove_column :payments, :product_id, :integer
  end
end
