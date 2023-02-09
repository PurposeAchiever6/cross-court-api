class AddApplyCcCashToSubscriptionToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :apply_cc_cash_to_subscription, :boolean, default: false
  end
end
