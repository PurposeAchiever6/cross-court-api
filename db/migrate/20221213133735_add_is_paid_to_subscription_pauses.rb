class AddIsPaidToSubscriptionPauses < ActiveRecord::Migration[6.0]
  def change
    add_column :subscription_pauses, :paid, :boolean, default: false
  end
end
