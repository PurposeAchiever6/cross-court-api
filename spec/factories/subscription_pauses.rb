# == Schema Information
#
# Table name: subscription_pauses
#
#  id              :integer          not null, primary key
#  paused_from     :datetime         not null
#  paused_until    :datetime         not null
#  subscription_id :integer
#  unpaused        :boolean          default(FALSE)
#  unpaused_at     :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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
    unpaused { false }
    unpaused_at { nil }
  end
end
