class AddSubscriptionCreditsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :subscription_credits, :integer, null: false, default: 0
  end
end
