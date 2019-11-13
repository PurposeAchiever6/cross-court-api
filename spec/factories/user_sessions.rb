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
#
# Indexes
#
#  index_user_sessions_on_session_id              (session_id)
#  index_user_sessions_on_user_id                 (user_id)
#  index_user_sessions_on_user_id_and_session_id  (user_id,session_id) UNIQUE
#

FactoryBot.define do
  factory :user_session do
    user
    session
  end
end
