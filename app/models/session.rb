# == Schema Information
#
# Table name: sessions
#
#  id                       :integer          not null, primary key
#  start_time               :date             not null
#  recurring                :text
#  time                     :time             not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  location_id              :integer          not null
#  end_time                 :date
#  skill_level_id           :integer
#  is_private               :boolean          default(FALSE)
#  coming_soon              :boolean          default(FALSE)
#  is_open_club             :boolean          default(FALSE)
#  duration_minutes         :integer          default(60)
#  deleted_at               :datetime
#  max_first_timers         :integer
#  women_only               :boolean          default(FALSE)
#  all_skill_levels_allowed :boolean          default(TRUE)
#
# Indexes
#
#  index_sessions_on_deleted_at      (deleted_at)
#  index_sessions_on_location_id     (location_id)
#  index_sessions_on_skill_level_id  (skill_level_id)
#

class Session < ApplicationRecord
  DATE_FORMAT = '%d-%m-%Y'.freeze
  YEAR_MONTH_DAY = '%Y-%m-%d'.freeze
  MONTH_NAME_FORMAT = '%B, %d %Y'.freeze
  DAY_MONTH_NAME_FORMAT = '%A %B %-e'.freeze
  TIME_FORMAT = '%l:%M %P'.freeze
  QUERY_TIME_FORMAT = 'HH24:MI'.freeze
  CANCELLATION_PERIOD = ENV['CANCELLATION_PERIOD'].to_i.hours.freeze
  MAX_CAPACITY = ENV['MAX_CAPACITY'].to_i.freeze

  acts_as_paranoid

  attr_accessor :employees_assigned

  serialize :recurring, Hash

  belongs_to :location, -> { with_deleted }, inverse_of: :sessions
  belongs_to :skill_level

  has_many :user_sessions
  has_many :referee_sessions
  has_many :sem_sessions
  has_many :user_session_waitlists
  has_many :user_session_votes
  has_many :users, through: :user_sessions
  has_many :session_exceptions, dependent: :destroy

  validates :start_time, :time, :duration_minutes, presence: true
  validates :end_time,
            absence: { message: 'must be blank if session is not recurring' },
            if: -> { single_occurrence? }

  delegate :name, :description, :time_zone, to: :location, prefix: true
  delegate :address, :time_zone, to: :location
  delegate :name, to: :skill_level, prefix: true

  accepts_nested_attributes_for :session_exceptions, allow_destroy: true

  after_update :remove_orphan_sessions
  before_destroy :check_for_future_user_sessions

  alias_attribute :open_club?, :is_open_club

  scope :visible_for, ->(user) { where(is_private: false) unless user&.private_access }

  scope :for_range, (lambda do |start_date, end_date|
    where('start_time >= ? AND start_time <= ?', start_date, end_date)
      .or(where.not(recurring: nil))
  end)

  scope :by_location, (lambda do |location_id|
    location_id.blank? ? all : where(location_id: location_id)
  end)

  def recurring=(value)
    super(RecurringSelect.dirty_hash_to_rule(value)&.to_hash)
  end

  def rule
    IceCube::Rule.from_hash recurring
  end

  def recurring_text
    recurring? ? IceCube::Rule.from_hash(recurring).to_s : 'Single occurrence'
  end

  def schedule
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule(rule.until(end_time))
    session_exceptions.each do |exception|
      schedule.add_exception_time(exception.date)
    end
    schedule
  end

  def calendar_events(start_date, end_date)
    if single_occurrence?
      self.employees_assigned = referee_sessions.present? && sem_sessions.present?
      [self]
    else
      schedule.occurrences_between(start_date, end_date).map do |date|
        Session.new(
          id: id,
          start_time: date,
          time: time,
          duration_minutes: duration_minutes,
          location_id: location_id,
          location: location,
          max_first_timers: max_first_timers,
          skill_level_id: skill_level_id,
          skill_level: skill_level,
          is_private: is_private,
          is_open_club: is_open_club,
          coming_soon: coming_soon,
          women_only: women_only,
          all_skill_levels_allowed: all_skill_levels_allowed
        )
      end
    end
  end

  def referee(date)
    referee_sessions.find_by(date: date)&.referee
  end

  def sem(date)
    sem_sessions.find_by(date: date)&.sem
  end

  def reservations_count(date)
    user_sessions.not_canceled.by_date(date).count
  end

  def not_canceled_reservations(date)
    user_sessions.not_canceled.by_date(date)
  end

  def first_timer_reservations(date, user_sessions = nil)
    reservations = user_sessions || not_canceled_reservations(date)

    ActiveRecord::Associations::Preloader.new.preload(
      reservations,
      user: :last_checked_in_user_session
    )

    reservations.select { |reservation| reservation.user.first_timer? }
  end

  def full?(date, user = nil)
    reservations = not_canceled_reservations(date)
    max_capacity = reservations.length >= MAX_CAPACITY

    return true if max_capacity
    return false unless max_first_timers && user&.first_timer?

    first_timer_reservations = first_timer_reservations(date, reservations)
    first_timer_reservations.length >= max_first_timers
  end

  def spots_left(date, user = nil)
    reservations = not_canceled_reservations(date)
    total_spots_left = MAX_CAPACITY - reservations.length

    return 0 unless total_spots_left.positive?
    return total_spots_left unless max_first_timers && user&.first_timer?

    first_timer_reservations = first_timer_reservations(date, reservations)
    first_timers_spots_left = max_first_timers - first_timer_reservations.length
    first_timers_spots_left.positive? ? first_timers_spots_left : 0
  end

  def waitlist(date)
    user_session_waitlists.by_date(date).sorted
  end

  def votes(date)
    return 0 unless coming_soon

    user_session_votes.by_date(date).count
  end

  def invalid_date?(date)
    no_session_for_date = if single_occurrence?
                            start_time != date
                          else
                            calendar_events(date, date).empty?
                          end

    no_session_for_date || past?(date)
  end

  def past?(date = nil)
    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
    date = start_time if date.blank?
    session_time = "#{date} #{time}".to_datetime

    current_time > session_time
  end

  def active?
    current_date = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone)).to_date

    if single_occurrence?
      current_date <= start_time
    else
      end_time ? current_date <= end_time : true
    end
  end

  def single_occurrence?
    !recurring?
  end

  def at_session_level?(user)
    return true if all_skill_levels_allowed

    user_skill_rating = user.skill_rating
    user_skill_rating >= skill_level.min && user_skill_rating <= skill_level.max
  end

  private

  def remove_orphan_sessions
    return unless saved_change_to_recurring? || saved_change_to_end_time?

    RemoveOrphanSessions.call(session: self)
  end

  def check_for_future_user_sessions
    if user_sessions.future.not_canceled.exists?
      errors.add(:base, 'The session has future user sessions reservations')
      throw(:abort)
    else
      referee_sessions.future.destroy_all
      sem_sessions.future.destroy_all
    end
  end
end
