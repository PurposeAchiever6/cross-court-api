class AddCreditReimbursedToUserSession < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :credit_reimbursed, :bool, null: false, default: false
  end
end
