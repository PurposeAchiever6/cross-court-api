class AddReasonToSubscriptionPauses < ActiveRecord::Migration[6.0]
  def change
    add_column :subscription_pauses, :reason, :string
  end
end
