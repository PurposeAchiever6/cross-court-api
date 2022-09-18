class AddCreditUsedTypeToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :credit_used_type, :integer
  end
end
