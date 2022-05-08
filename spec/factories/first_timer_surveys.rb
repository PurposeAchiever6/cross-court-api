# == Schema Information
#
# Table name: first_timer_surveys
#
#  id                       :integer          not null, primary key
#  how_do_you_hear_about_us :string
#  user_id                  :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_first_timer_surveys_on_user_id  (user_id)
#

FactoryBot.define do
  factory :first_timer_survey do
    user
    how_do_you_hear_about_us { Faker::Lorem.word }
  end
end
