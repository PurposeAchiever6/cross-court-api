class AddFirstTimeSubscriptionCreditsUsedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :first_time_subscription_credits_used_at, :datetime
  end
end
