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

FactoryBot.define do
  factory :subscription_cancellation_request do
    status { :pending }
    reason { 'Some Reason!' }
    user

    after :create do |subscription_cancellation_request|
      subscription_cancellation_request.user.subscriptions << create(:subscription)
    end
  end
end
