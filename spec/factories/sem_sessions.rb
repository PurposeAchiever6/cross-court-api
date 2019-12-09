# == Schema Information
#
# Table name: sem_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer          not null
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sem_sessions_on_session_id                       (session_id)
#  index_sem_sessions_on_user_id                          (user_id)
#  index_sem_sessions_on_user_id_and_session_id_and_date  (user_id,session_id,date) UNIQUE
#

FactoryBot.define do
  factory :sem_session do
    session
    user
    date { Date.tomorrow }
  end
end
