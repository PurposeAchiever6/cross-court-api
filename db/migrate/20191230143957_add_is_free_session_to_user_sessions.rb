class AddIsFreeSessionToUserSessions < ActiveRecord::Migration[6.0]
  def change
    change_table :user_sessions, bulk: true do |t|
      t.boolean :is_free_session, null: false, default: false
      t.string :free_session_payment_intent
    end
  end
end
