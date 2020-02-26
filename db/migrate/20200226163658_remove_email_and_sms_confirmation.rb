class RemoveEmailAndSmsConfirmation < ActiveRecord::Migration[6.0]
  def up
    change_table :user_sessions, bulk: true do |t|
      t.remove :email_reminder_sent
      t.remove :sms_reminder_sent
    end
  end

  def down
    change_table :user_sessions, bulk: true do |t|
      t.boolean :email_reminder_sent, null: false, default: false
      t.boolean :sms_reminder_sent, null: false, default: false
    end
  end
end
