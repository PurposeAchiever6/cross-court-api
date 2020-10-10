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
#  credit_reimbursed           :boolean          default(FALSE), not null
#  referral_id                 :integer
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

  belongs_to :referral, class_name: 'User', foreign_key: :referral_id, optional: true, inverse_of: :user_sessions

  has_many :session_survey_answers, dependent: :destroy

  validates :state, :date, presence: true

  delegate :time, :time_zone, :location, :location_name, :location_description, to: :session
  delegate :phone_number, :email, to: :user, prefix: true

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
  scope :ordered_by_date, -> { order(:date) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_date, ->(date) { where(date: date) }
  scope :by_session, ->(session_id) { where(session_id: session_id) }

  def in_cancellation_time?
    remaining_time > Session::CANCELLATION_PERIOD
  end

  def in_confirmation_time?
    remaining_time.between?(Session::CANCELLATION_PERIOD, 24.hours)
  end

  def create_ics_event
    start_datetime = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec).in_time_zone(time_zone)

    options = { 'CN' => 'Crosscourt' }
    organizer_property = RiCal::PropertyValue::CalAddress.new(nil, value: 'mailto:ccteam@cross-court.com', params: options)

    event = RiCal.Calendar do |cal|
      cal.event do |calendar_event|
        calendar_event.summary = "Crosscourt - #{location_name}"
        calendar_event.description = location_description
        calendar_event.dtstart = start_datetime
        calendar_event.dtend = start_datetime + 1.hour
        calendar_event.location = location.full_address
        calendar_event.organizer_property = organizer_property
      end
    end

    event
  end

  private

  def remaining_time
    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
    session_time = "#{date} #{time}".to_datetime
    session_time.to_i - current_time.to_i
  end
end
