class ChangeSubscriptionPauses < ActiveRecord::Migration[6.0]
  def change
    remove_column :subscription_pauses, :unpaused_at, :datetime
    remove_column :subscription_pauses, :unpaused, :boolean
    add_column :subscription_pauses, :job_id, :string
    add_column :subscription_pauses, :status, :integer, default: 0
    add_column :subscription_pauses, :canceled_at, :datetime
  end
end
