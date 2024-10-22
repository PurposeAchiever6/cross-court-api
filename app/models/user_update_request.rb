# == Schema Information
#
# Table name: user_update_requests
#
#  id                   :bigint           not null, primary key
#  status               :integer          default("pending")
#  requested_attributes :json
#  reason               :text
#  user_id              :bigint
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_user_update_requests_on_status   (status)
#  index_user_update_requests_on_user_id  (user_id)
#

class UserUpdateRequest < ApplicationRecord
  has_paper_trail on: %i[update destroy]

  enum status: { pending: 0, approved: 1, rejected: 2, ignored: 3 }

  belongs_to :user

  def readable_requested_attributes
    requested_attributes.map do |column, new_value|
      "#{column.humanize} from #{user.send(column.to_sym)} to #{new_value}"
    end
  end
end
