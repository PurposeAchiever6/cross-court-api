# == Schema Information
#
# Table name: subscription_cancellation_requests
#
#  id         :bigint           not null, primary key
#  reason     :text
#  user_id    :bigint
#  status     :integer          default("pending")
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_subscription_cancellation_requests_on_status   (status)
#  index_subscription_cancellation_requests_on_user_id  (user_id)
#

class SubscriptionCancellationRequest < ApplicationRecord
  has_paper_trail on: %i[update destroy]

  enum status: {
    pending: 0,
    ignored: 1,
    cancel_at_current_period_end: 2,
    cancel_at_next_month_period_end: 3,
    cancel_immediately: 4,
    cancel_by_user: 5
  }

  belongs_to :user

  delegate :url_helpers, to: 'Rails.application.routes'

  scope :addressed, -> { not_pending }
  scope :for_user, ->(user) { where(user:) }

  def url
    url_helpers.admin_subscription_cancellation_request_url(id, host: ENV.fetch('SERVER_URL', nil))
  end
end
