# == Schema Information
#
# Table name: user_sessions
#
#  id                              :integer          not null, primary key
#  user_id                         :integer          not null
#  session_id                      :integer          not null
#  state                           :integer          default("reserved"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  date                            :date             not null
#  checked_in                      :boolean          default(FALSE), not null
#  is_free_session                 :boolean          default(FALSE), not null
#  free_session_payment_intent     :string
#  credit_reimbursed               :boolean          default(FALSE), not null
#  referral_id                     :integer
#  jersey_rental                   :boolean          default(FALSE)
#  jersey_rental_payment_intent_id :string
#  assigned_team                   :string
#  no_show_up_fee_charged          :boolean          default(FALSE)
#  reminder_sent_at                :datetime
#  first_session                   :boolean          default(FALSE)
#  credit_used_type                :integer
#  goal                            :string
#  scouting                        :boolean          default(FALSE)
#
# Indexes
#
#  index_user_sessions_on_referral_id  (referral_id)
#  index_user_sessions_on_session_id   (session_id)
#  index_user_sessions_on_user_id      (user_id)
#

class UserSession < ApplicationRecord
  enum state: { reserved: 0, canceled: 1, confirmed: 2 }
  enum credit_used_type: { credits: 0,
                           subscription_credits: 1,
                           subscription_skill_session_credits: 2,
                           credits_without_expiration: 3 }

  alias_attribute :checked, :checked_in # This is to make the checked_in filter work in the admin

  belongs_to :user
  belongs_to :session, -> { with_deleted }, inverse_of: :user_sessions

  belongs_to :referral, class_name: 'User', optional: true

  has_one :shooting_machine_reservation,
          -> { not_canceled },
          inverse_of: :user_session,
          dependent: nil

  has_many :session_survey_answers, dependent: :destroy
  has_many :session_guests, dependent: :destroy

  validates :state, :date, presence: true
  validate :user_valid_age

  delegate :time,
           :time_zone,
           :location,
           :location_name,
           :location_description,
           :skill_session,
           to: :session
  delegate :phone_number, :email, :full_name,
           to: :user,
           prefix: true

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
  scope :by_user, ->(user_id) { where(user_id:) }
  scope :by_date, ->(date) { where(date:) }
  scope :by_session, ->(session_id) { where(session_id:) }
  scope :checked_in, -> { where(checked_in: true) }
  scope :not_checked_in, -> { where(checked_in: false) }
  scope :first_sessions, -> { where(first_session: true) }
  scope :not_first_sessions, -> { where(first_session: false) }
  scope :free_sessions, -> { where(is_free_session: true) }
  scope :not_free_sessions, -> { where(is_free_session: false) }
  scope :no_show_up_fee_not_charged, -> { where(no_show_up_fee_charged: false) }
  scope :skill_sessions, -> { joins(:session).where(sessions: { skill_session: true }) }
  scope :not_skill_sessions, -> { joins(:session).where(sessions: { skill_session: false }) }
  scope :not_open_club, -> { joins(:session).where(sessions: { is_open_club: false }) }

  def in_cancellation_time?
    remaining_time > Session::CANCELLATION_PERIOD
  end

  def in_confirmation_time?
    remaining_time.between?(Session::CANCELLATION_PERIOD, 24.hours)
  end

  def create_ics_event
    tz = Time.find_zone(time_zone)

    start_datetime = Time.new(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.min,
      time.sec,
      tz
    ).utc

    options = { 'CN' => 'Crosscourt' }
    organizer_property = RiCal::PropertyValue::CalAddress.new(
      nil,
      value: "mailto:#{ENV.fetch('CC_TEAM_EMAIL', nil)}",
      params: options
    )

    RiCal.Calendar do |cal|
      cal.event do |calendar_event|
        calendar_event.summary = "Crosscourt - #{location_name}"
        calendar_event.description = location_description
        calendar_event.dtstart = start_datetime
        calendar_event.dtend = start_datetime + 1.hour
        calendar_event.location = location.full_address
        calendar_event.organizer_property = organizer_property
      end
    end
  end

  def invite_link
    front_end_url = ENV.fetch('FRONTENT_URL', nil)
    formatted_date = date.strftime(Session::YEAR_MONTH_DAY)
    "#{front_end_url}/session/#{session.id}/#{formatted_date}"
  end

  def date_when_format
    today = Time.current.in_time_zone(time_zone).to_date

    case date
    when today
      'today'
    when today + 1.day
      'tomorrow'
    else
      date.strftime(Session::DAY_MONTH_NAME_FORMAT)
    end
  end

  def to_s
    "#{user_full_name}: #{date_when_format} - #{time.strftime(Session::TIME_FORMAT)}"
  end

  private

  def user_valid_age
    user_age = user&.age

    return unless user_age

    errors.add(:user_age, "can't be under 18 years old") if user_age < 18
  end

  def remaining_time
    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
    session_time = "#{date} #{time}".to_datetime
    session_time.to_i - current_time.to_i
  end
end
