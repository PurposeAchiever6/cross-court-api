class AddIndexToSubscriptionCancellationRequests < ActiveRecord::Migration[6.0]
  def change
    add_index :subscription_cancellation_requests, :status
  end
end
