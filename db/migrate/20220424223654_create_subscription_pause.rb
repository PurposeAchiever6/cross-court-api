class CreateSubscriptionPause < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_pauses do |t|
      t.datetime :paused_from, null: false
      t.datetime :paused_until, null: false
      t.belongs_to :subscription
      t.boolean :unpaused, default: false
      t.datetime :unpaused_at
      t.timestamps
    end
  end
end
