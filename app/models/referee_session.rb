# == Schema Information
#
# Table name: referee_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_referee_sessions_on_session_id                       (session_id)
#  index_referee_sessions_on_user_id                          (user_id)
#  index_referee_sessions_on_user_id_and_session_id_and_date  (user_id,session_id,date) UNIQUE
#

class RefereeSession < ApplicationRecord
  belongs_to :user
  belongs_to :session, optional: true
  alias_attribute :referee, :user

  validates :date, presence: true

  after_validation :destroy_previous_assignment

  scope :by_date, ->(date) { where(date: date) }

  private

  def destroy_previous_assignment
    RefereeSession.where(session_id: session_id, date: date).where.not(id: id).destroy_all
  end
end
