# == Schema Information
#
# Table name: user_sessions
#
#  id                              :integer          not null, primary key
#  user_id                         :integer          not null
#  session_id                      :integer          not null
#  state                           :integer          default("reserved"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  date                            :date             not null
#  checked_in                      :boolean          default(FALSE), not null
#  is_free_session                 :boolean          default(FALSE), not null
#  free_session_payment_intent     :string
#  credit_reimbursed               :boolean          default(FALSE), not null
#  referral_id                     :integer
#  jersey_rental                   :boolean          default(FALSE)
#  jersey_rental_payment_intent_id :string
#  assigned_team                   :string
#  no_show_up_fee_charged          :boolean          default(FALSE)
#  reminder_sent_at                :datetime
#  first_session                   :boolean          default(FALSE)
#  credit_used_type                :integer
#  goal                            :string
#  scouting                        :boolean          default(FALSE)
#
# Indexes
#
#  index_user_sessions_on_session_id  (session_id)
#  index_user_sessions_on_user_id     (user_id)
#

FactoryBot.define do
  factory :user_session do
    user
    session
    date { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')).to_date }
    state { 'reserved' }
    first_session { false }
    is_free_session { false }
    checked_in { false }
    no_show_up_fee_charged { false }
    credit_used_type { :credits }
    scouting { false }
  end
end
