# == Schema Information
#
# Table name: session_surveys
#
#  id              :bigint           not null, primary key
#  rate            :integer
#  feedback        :text
#  user_id         :bigint
#  user_session_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_session_surveys_on_user_id          (user_id)
#  index_session_surveys_on_user_session_id  (user_session_id)
#
FactoryBot.define do
  factory :session_survey do
    user
    user_session
    rate { rand(1..5) }
    feedback { Faker::Lorem.paragraph }
  end
end
