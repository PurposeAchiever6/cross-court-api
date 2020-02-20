# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  start_time  :date             not null
#  recurring   :text
#  time        :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer          not null
#  end_time    :date
#  level       :integer          default(0), not null
#
# Indexes
#
#  index_sessions_on_location_id  (location_id)
#

FactoryBot.define do
  factory :session do
    location
    start_time { Date.current }
    time       { Time.current.in_time_zone('America/Los_Angeles') + 1.minute }

    trait :daily do
      recurring { IceCube::Rule.daily }
    end
  end
end
