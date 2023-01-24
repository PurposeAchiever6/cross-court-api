# == Schema Information
#
# Table name: subscription_pauses
#
#  id              :bigint           not null, primary key
#  paused_from     :datetime         not null
#  paused_until    :datetime         not null
#  subscription_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  job_id          :string
#  status          :integer          default("upcoming")
#  canceled_at     :datetime
#  unpaused_at     :datetime
#  reason          :string
#  paid            :boolean          default(FALSE)
#
# Indexes
#
#  index_subscription_pauses_on_subscription_id  (subscription_id)
#

FactoryBot.define do
  factory :subscription_pause do
    subscription
    paused_from { Time.current }
    paused_until { 1.month.from_now }
    status { :upcoming }
    paid { false }
  end
end
