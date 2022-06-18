# == Schema Information
#
# Table name: user_session_waitlists
#
#  id         :integer          not null, primary key
#  date       :date
#  user_id    :integer
#  session_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state      :integer
#
# Indexes
#
#  index_user_session_waitlists_on_date_and_session_id_and_user_id  (date,session_id,user_id) UNIQUE
#  index_user_session_waitlists_on_session_id                       (session_id)
#  index_user_session_waitlists_on_user_id                          (user_id)
#

class UserSessionWaitlist < ApplicationRecord
  MINUTES_TOLERANCE = ENV['WAITLIST_MINUTES_TOLERANCE'].to_i.minutes.freeze

  enum state: {
    success: 0,
    pending: 1,
    timeout: 2
  }

  belongs_to :user
  belongs_to :session

  validates :date, presence: true, uniqueness: { scope: %i[session_id user_id] }

  scope :by_date, ->(date) { where(date: date) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def self.sorted
    joins(:user).left_outer_joins(user: :active_subscription)
                .order(state: :asc, 'subscriptions.status': :asc, created_at: :asc)
  end
end
