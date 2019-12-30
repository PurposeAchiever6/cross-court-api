class AddClaimedFreeSessionToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.integer :free_session_state, null: false, default: 0
      t.string :free_session_payment_intent
    end
  end
end
