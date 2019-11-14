# == Schema Information
#
# Table name: user_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer          not null
#  state      :integer          default("reserved"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  date       :date             not null
#
# Indexes
#
#  index_user_sessions_on_date_and_user_id_and_session_id  (date,user_id,session_id) UNIQUE
#  index_user_sessions_on_session_id                       (session_id)
#  index_user_sessions_on_user_id                          (user_id)
#

FactoryBot.define  do
  factory :user_session do
    user
    session
    date { Date.current }
  end
end
