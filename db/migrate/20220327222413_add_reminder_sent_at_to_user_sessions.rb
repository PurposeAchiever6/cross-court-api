class AddReminderSentAtToUserSessions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_sessions, :reminder_sent_at, :datetime
  end
end
