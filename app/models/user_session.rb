# == Schema Information
#
# Table name: user_sessions
#
#  id                          :integer          not null, primary key
#  user_id                     :integer          not null
#  session_id                  :integer          not null
#  state                       :integer          default("reserved"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  date                        :date             not null
#  checked_in                  :boolean          default(FALSE), not null
#  is_free_session             :boolean          default(FALSE), not null
#  free_session_payment_intent :string
#
# Indexes
#
#  index_user_sessions_on_session_id  (session_id)
#  index_user_sessions_on_user_id     (user_id)
#

class UserSession < ApplicationRecord
  enum state: { reserved: 0, canceled: 1, confirmed: 2 }

  belongs_to :user
  belongs_to :session

  validates :state, :date, presence: true

  delegate :time, :time_zone, to: :session
  delegate :phone_number, :name, :email, to: :user, prefix: true

  scope :not_canceled, -> { where.not(state: :canceled) }
  scope :past, (lambda do
    joins(session: :location)
      .where('date < (current_timestamp at time zone locations.time_zone)::date OR
             (date = (current_timestamp at time zone locations.time_zone)::date AND
             to_char(current_timestamp at time zone locations.time_zone, :time_format) >
             to_char(time, :time_format))', time_format: Session::QUERY_TIME_FORMAT)
  end)
  scope :future, (lambda do
    joins(session: :location)
      .where('date > (current_timestamp at time zone locations.time_zone)::date OR
             (date = (current_timestamp at time zone locations.time_zone)::date AND
             to_char(current_timestamp at time zone locations.time_zone, :time_format) <
             to_char(time, :time_format))', time_format: Session::QUERY_TIME_FORMAT)
  end)
  scope :for_yesterday, (lambda do
    joins(session: :location)
      .where('date = (current_timestamp at time zone locations.time_zone)::date - 1')
  end)
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_date, ->(date) { where(date: date) }
  scope :by_session, ->(session_id) { where(session_id: session_id) }

  def in_cancellation_time?
    current_time = Time.current.in_time_zone(time_zone)
    today = current_time.to_date
    max_cancellation_time = (time - Session::CANCELLATION_PERIOD)

    today < date || today == date && current_time.strftime(Session::TIME_FORMAT) <
      max_cancellation_time.strftime(Session::TIME_FORMAT)
  end

  def in_confirmation_time?
    current_time = Time.current.in_time_zone(time_zone)
    session_time = "#{date} #{time}".to_datetime
    time_difference = session_time.to_i - current_time.to_i
    time_difference < 2.days
  end
end
