class AddCcCashToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :referral_cc_cash, :decimal, default: 0
  end
end
