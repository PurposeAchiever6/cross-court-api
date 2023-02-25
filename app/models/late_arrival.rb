# == Schema Information
#
# Table name: late_arrivals
#
#  id              :bigint           not null, primary key
#  user_id         :bigint
#  user_session_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_late_arrivals_on_user_id                      (user_id)
#  index_late_arrivals_on_user_id_and_user_session_id  (user_id,user_session_id) UNIQUE
#  index_late_arrivals_on_user_session_id              (user_session_id)
#
class LateArrival < ApplicationRecord
  belongs_to :user
  belongs_to :user_session

  validates :user_id, uniqueness: { scope: :user_session_id }
end
