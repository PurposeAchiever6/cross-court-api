# == Schema Information
#
# Table name: user_session_votes
#
#  id         :integer          not null, primary key
#  date       :date
#  user_id    :integer
#  session_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_session_votes_on_date_and_session_id_and_user_id  (date,session_id,user_id) UNIQUE
#  index_user_session_votes_on_session_id                       (session_id)
#  index_user_session_votes_on_user_id                          (user_id)
#

FactoryBot.define do
  factory :user_session_vote do
    user
    session
    date { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')).to_date }
  end
end
