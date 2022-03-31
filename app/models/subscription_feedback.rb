# == Schema Information
#
# Table name: subscription_feedbacks
#
#  id       :integer          not null, primary key
#  feedback :text
#  user_id  :integer
#
# Indexes
#
#  index_subscription_feedbacks_on_user_id  (user_id)
#

class SubscriptionFeedback < ApplicationRecord
  belongs_to :user

  delegate :url_helpers, to: 'Rails.application.routes'

  def url
    url_helpers.admin_subscription_feedback_url(id, host: ENV['SERVER_URL'])
  end
end
