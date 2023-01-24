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

class SubscriptionPause < ApplicationRecord
  belongs_to :subscription

  has_many :payments, as: :chargeable, dependent: :nullify

  enum status: { upcoming: 0, actual: 1, finished: 2, canceled: 3, unpaused: 4 }

  scope :this_year, -> { where(created_at: Time.zone.today.all_year) }
  scope :free, -> { where(paid: false) }
  scope :upcoming_or_actual, -> { where(status: %i[upcoming actual]) }
end
