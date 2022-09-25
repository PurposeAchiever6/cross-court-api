# == Schema Information
#
# Table name: subscription_cancellation_requests
#
#  id      :integer          not null, primary key
#  reason  :text
#  user_id :integer
#  status  :integer          default(0)
#
# Indexes
#
#  index_subscription_cancellation_requests_on_user_id  (user_id)
#

class SubscriptionCancellationRequest < ApplicationRecord
  belongs_to :user

  delegate :url_helpers, to: 'Rails.application.routes'

  def url
    url_helpers.admin_subscription_cancellation_request_url(id, host: ENV['SERVER_URL'])
  end
end
