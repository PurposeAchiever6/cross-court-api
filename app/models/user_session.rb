# == Schema Information
#
# Table name: user_sessions
#
#  id                  :integer          not null, primary key
#  user_id             :integer          not null
#  session_id          :integer          not null
#  state               :integer          default("reserved"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  date                :date             not null
#  sms_reminder_sent   :boolean          default(FALSE), not null
#  email_reminder_sent :boolean          default(FALSE), not null
#
# Indexes
#
#  index_user_sessions_on_date_and_user_id_and_session_id  (date,user_id,session_id) UNIQUE
#  index_user_sessions_on_email_reminder_sent              (email_reminder_sent)
#  index_user_sessions_on_session_id                       (session_id)
#  index_user_sessions_on_sms_reminder_sent                (sms_reminder_sent)
#  index_user_sessions_on_user_id                          (user_id)
#

class UserSession < ApplicationRecord
  enum state: { reserved: 0, canceled: 1, confirmed: 2 }

  belongs_to :user
  belongs_to :session

  validates :state, :date, presence: true
  validates :date, uniqueness: { scope: %i[session_id user_id] }

  delegate :time, :time_zone, to: :session
  delegate :phone_number, :name, :email, to: :user, prefix: true

  scope :email_not_sent, -> { where(email_reminder_sent: false) }
  scope :sms_not_sent, -> { where(sms_reminder_sent: false) }
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

  def in_cancellation_time?
    current_time = Time.current.in_time_zone(time_zone)
    today = current_time.to_date
    max_cancellation_time = (time - Session::CANCELATION_PERIOD)

    today < date || today == date && current_time.strftime(Session::TIME_FORMAT) <
      max_cancellation_time.strftime(Session::TIME_FORMAT)
  end
end
