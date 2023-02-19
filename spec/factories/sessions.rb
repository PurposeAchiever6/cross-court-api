# == Schema Information
#
# Table name: sessions
#
#  id                       :bigint           not null, primary key
#  start_time               :date             not null
#  recurring                :text
#  time                     :time             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  location_id              :bigint           not null
#  end_time                 :date
#  skill_level_id           :bigint
#  is_private               :boolean          default(FALSE)
#  coming_soon              :boolean          default(FALSE)
#  is_open_club             :boolean          default(FALSE)
#  duration_minutes         :integer          default(60)
#  deleted_at               :datetime
#  max_first_timers         :integer
#  women_only               :boolean          default(FALSE)
#  all_skill_levels_allowed :boolean          default(TRUE)
#  max_capacity             :integer          default(15)
#  skill_session            :boolean          default(FALSE)
#  cc_cash_earned           :decimal(, )      default(0.0)
#  default_referee_id       :integer
#  default_sem_id           :integer
#  default_coach_id         :integer
#  guests_allowed           :integer
#  guests_allowed_per_user  :integer
#  members_only             :boolean          default(FALSE)
#  theme_title              :string
#  theme_subheading         :string
#  theme_sweat_level        :integer
#  theme_description        :text
#  cost_credits             :integer          default(1)
#
# Indexes
#
#  index_sessions_on_default_coach_id    (default_coach_id)
#  index_sessions_on_default_referee_id  (default_referee_id)
#  index_sessions_on_default_sem_id      (default_sem_id)
#  index_sessions_on_deleted_at          (deleted_at)
#  index_sessions_on_location_id         (location_id)
#  index_sessions_on_skill_level_id      (skill_level_id)
#  index_sessions_on_start_time          (start_time)
#

FactoryBot.define do
  los_angeles_time = Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))

  factory :session do
    location
    skill_level
    start_time { los_angeles_time.to_date }
    time { los_angeles_time + 1.minute }
    is_private { false }
    duration_minutes { 60 }
    is_open_club { false }
    max_capacity { 15 }
    max_first_timers { nil }
    cc_cash_earned { 0 }
    guests_allowed { nil }
    guests_allowed_per_user { nil }
    members_only { false }

    trait :daily do
      recurring { IceCube::Rule.daily }
    end
  end
end
