# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  start_time     :date             not null
#  recurring      :text
#  time           :time             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  location_id    :integer          not null
#  end_time       :date
#  skill_level_id :integer
#  is_private     :boolean          default(FALSE)
#
# Indexes
#
#  index_sessions_on_location_id     (location_id)
#  index_sessions_on_skill_level_id  (skill_level_id)
#

FactoryBot.define do
  los_angeles_time = Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))

  factory :session do
    location
    skill_level
    start_time { los_angeles_time.to_date }
    time       { los_angeles_time + 1.minute }
    is_private { false }

    trait :daily do
      recurring { IceCube::Rule.daily }
    end
  end
end
