# == Schema Information
#
# Table name: user_sessions
#
#  id                          :integer          not null, primary key
#  user_id                     :integer          not null
#  session_id                  :integer          not null
#  state                       :integer          default("reserved"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  date                        :date             not null
#  sms_reminder_sent           :boolean          default(FALSE), not null
#  email_reminder_sent         :boolean          default(FALSE), not null
#  checked_in                  :boolean          default(FALSE), not null
#  is_free_session             :boolean          default(FALSE), not null
#  free_session_payment_intent :string
#
# Indexes
#
#  index_user_sessions_on_email_reminder_sent  (email_reminder_sent)
#  index_user_sessions_on_session_id           (session_id)
#  index_user_sessions_on_sms_reminder_sent    (sms_reminder_sent)
#  index_user_sessions_on_user_id              (user_id)
#

FactoryBot.define do
  factory :user_session do
    user
    session
    date { Date.current }
  end
end
