class AddUserSubscriptionNameToUserSessions < ActiveRecord::Migration[7.0]
  def change
    add_column :user_sessions, :user_subscription_name, :string
  end
end
