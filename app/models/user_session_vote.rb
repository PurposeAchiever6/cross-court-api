# == Schema Information
#
# Table name: user_session_votes
#
#  id         :bigint           not null, primary key
#  date       :date
#  user_id    :bigint
#  session_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_session_votes_on_date_and_session_id_and_user_id  (date,session_id,user_id) UNIQUE
#  index_user_session_votes_on_session_id                       (session_id)
#  index_user_session_votes_on_user_id                          (user_id)
#

class UserSessionVote < ApplicationRecord
  belongs_to :user
  belongs_to :session

  validates :date, presence: true, uniqueness: { scope: %i[session_id user_id] }

  scope :by_date, ->(date) { where(date:) }
  scope :by_user, ->(user_id) { where(user_id:) }
end
