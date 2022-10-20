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
#
# Indexes
#
#  index_subscription_pauses_on_subscription_id  (subscription_id)
#

class SubscriptionPause < ApplicationRecord
  belongs_to :subscription

  enum status: { upcoming: 0, actual: 1, finished: 2, canceled: 3, unpaused: 4 }

  scope :this_year, -> { where(created_at: Time.zone.today.all_year) }
  scope :upcoming_or_actual, -> { where(status: %i[upcoming actual]) }
end
