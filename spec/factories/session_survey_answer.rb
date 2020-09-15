FactoryBot.define do
  factory :session_survey_answer do
    answer { Faker::Lorem.paragraph }
    session_survey_question
    user_session
  end
end
