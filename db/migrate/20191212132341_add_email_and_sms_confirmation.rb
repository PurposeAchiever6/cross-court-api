class AddEmailAndSmsConfirmation < ActiveRecord::Migration[6.0]
  def change
    change_table :user_sessions, bulk: true do |t|
      t.boolean :sms_reminder_sent, null: false, default: false, index: true
      t.boolean :email_reminder_sent, null: false, default: false, index: true
    end
  end
end
