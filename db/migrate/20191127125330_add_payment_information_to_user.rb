class AddPaymentInformationToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.string :payment_method
      t.date :credit_expiration_date
      t.integer :credits, null: false, default: 0
    end
  end
end
