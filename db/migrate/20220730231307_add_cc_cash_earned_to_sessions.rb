class AddCcCashEarnedToSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :sessions, :cc_cash_earned, :decimal, default: 0
  end
end
