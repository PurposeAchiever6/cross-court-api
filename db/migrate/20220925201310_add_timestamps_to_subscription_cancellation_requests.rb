class AddTimestampsToSubscriptionCancellationRequests < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :subscription_cancellation_requests, null: true
  end
end
