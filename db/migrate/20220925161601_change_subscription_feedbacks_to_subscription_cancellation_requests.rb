class ChangeSubscriptionFeedbacksToSubscriptionCancellationRequests < ActiveRecord::Migration[6.0]
  def change
    rename_table :subscription_feedbacks, :subscription_cancellation_requests

    rename_column :subscription_cancellation_requests, :feedback, :reason

    add_column :subscription_cancellation_requests, :status, :integer, default: 0
  end
end
