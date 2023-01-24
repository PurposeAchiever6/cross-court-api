# == Schema Information
#
# Table name: first_timer_surveys
#
#  id                        :bigint           not null, primary key
#  user_id                   :bigint
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  how_did_you_hear_about_us :string
#
# Indexes
#
#  index_first_timer_surveys_on_user_id  (user_id)
#

FactoryBot.define do
  factory :first_timer_survey do
    user
    how_did_you_hear_about_us { Faker::Lorem.word }
  end
end
