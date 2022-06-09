class AddUnpausedAtToSubscriptionPauses < ActiveRecord::Migration[6.0]
  def change
    add_column :subscription_pauses, :unpaused_at, :datetime
  end
end
