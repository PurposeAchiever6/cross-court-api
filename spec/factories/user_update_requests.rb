# == Schema Information
#
# Table name: user_update_requests
#
#  id                   :integer          not null, primary key
#  status               :integer          default("pending")
#  requested_attributes :json             default({})
#  reason               :text
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_user_update_requests_on_status   (status)
#  index_user_update_requests_on_user_id  (user_id)
#

FactoryBot.define do
  factory :user_update_request do
    user
    status { :pending }
    requested_attributes { {} }
    reason { 'Some Reason!' }
  end
end
