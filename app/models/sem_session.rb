# == Schema Information
#
# Table name: sem_sessions
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
#  index_sem_sessions_on_session_id                       (session_id)
#  index_sem_sessions_on_user_id                          (user_id)
#  index_sem_sessions_on_user_id_and_session_id_and_date  (user_id,session_id,date) UNIQUE
#

class SemSession < ApplicationRecord
  belongs_to :user
  belongs_to :session, optional: true
  alias_attribute :sem, :user

  validates :date, presence: true

  after_validation :destroy_previous_assignment

  scope :future, (lambda do
    joins(session: :location)
      .where('date >= (current_timestamp at time zone locations.time_zone)::date')
  end)

  private

  def destroy_previous_assignment
    SemSession.where(session_id: session_id, date: date).where.not(id: id).destroy_all
  end
end
