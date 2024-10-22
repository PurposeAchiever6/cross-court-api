# == Schema Information
#
# Table name: user_session_waitlists
#
#  id         :bigint           not null, primary key
#  date       :date
#  user_id    :bigint
#  session_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state      :integer          default("pending")
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

  scope :by_date, ->(date) { where(date:) }
  scope :by_user, ->(user_id) { where(user_id:) }

  def self.sorted
    joins(:user).left_outer_joins(user: { active_subscription: :product })
                .order(state: :asc,
                       'subscriptions.status': :asc,
                       'products.price': :desc,
                       created_at: :asc)
  end
end
