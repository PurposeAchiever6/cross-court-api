# == Schema Information
#
# Table name: user_session_waitlists
#
#  id         :integer          not null, primary key
#  date       :date
#  user_id    :integer
#  session_id :integer
#  state      :integer
#
# Indexes
#
#  index_user_session_waitlists_on_date_and_session_id_and_user_id  (date,session_id,user_id) UNIQUE
#  index_user_session_waitlists_on_session_id                       (session_id)
#  index_user_session_waitlists_on_user_id                          (user_id)
#

FactoryBot.define do
  factory :user_session_waitlist do
    user
    session
    date { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')).to_date }
    state { :pending }
  end
end
