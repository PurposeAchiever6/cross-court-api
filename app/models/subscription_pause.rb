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

class SubscriptionPause < ApplicationRecord
  belongs_to :subscription

  scope :unpaused, -> { where(unpaused: false) }
  scope :this_year, -> { where(created_at: Time.zone.today.all_year) }
end
