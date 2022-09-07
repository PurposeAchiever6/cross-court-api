class AddMarkCancelAtPeriodEndAtToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :mark_cancel_at_period_end_at, :date
  end
end
