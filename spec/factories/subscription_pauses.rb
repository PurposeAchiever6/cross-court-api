# == Schema Information
#
# Table name: subscription_pauses
#
#  id              :integer          not null, primary key
#  paused_from     :datetime         not null
#  paused_until    :datetime         not null
#  subscription_id :integer
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
    paused_until { Time.current + 1.month }
    status { :upcoming }
    paid { false }
  end
end
