FactoryBot.define do
  factory :session_survey_question do
    question     { Faker::Lorem.paragraph }
    is_enabled   { [true, false].sample }
    is_mandatory { [true, false].sample }
  end
end
