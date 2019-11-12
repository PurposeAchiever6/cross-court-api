# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  start_time  :date             not null
#  recurring   :text
#  time        :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer          not null
#
# Indexes
#
#  index_sessions_on_location_id  (location_id)
#

FactoryBot.define do
  factory :session do
    location
    name       { Faker::Lorem.sentence }
    start_time { Time.current }
    time       { Time.current }
  end
end
