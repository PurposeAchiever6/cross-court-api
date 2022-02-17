# == Schema Information
#
# Table name: sessions
#
#  id             :integer          not null, primary key
#  start_time     :date             not null
#  recurring      :text
#  time           :time             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  location_id    :integer          not null
#  end_time       :date
#  skill_level_id :integer
#  is_private     :boolean          default(FALSE)
#  coming_soon    :boolean          default(FALSE)
#
# Indexes
#
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

  attr_accessor :employees_assigned

  serialize :recurring, Hash

  belongs_to :location, with_deleted: true
  belongs_to :skill_level

  has_many :user_sessions, dependent: :destroy
  has_many :users, through: :user_sessions
  has_many :session_exceptions, dependent: :destroy
  has_many :referee_sessions, dependent: :nullify
  has_many :sem_sessions, dependent: :nullify
  has_many :user_session_waitlists, dependent: :destroy

  validates :start_time, :time, presence: true
  validates :end_time,
            absence: { message: 'must be blank if session is not recurring' },
            if: -> { recurring.empty? }

  delegate :name, :description, :time_zone, to: :location, prefix: true
  delegate :address, :time_zone, to: :location
  delegate :name, to: :skill_level, prefix: true

  accepts_nested_attributes_for :session_exceptions, allow_destroy: true

  after_update :remove_orphan_sessions

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
    if recurring.empty?
      self.employees_assigned = referee_sessions.present? && sem_sessions.present?
      [self]
    else
      schedule.occurrences_between(start_date, end_date).map do |date|
        Session.new(
          id: id,
          start_time: date,
          time: time,
          location_id: location_id,
          location: location,
          skill_level_id: skill_level_id,
          skill_level: skill_level,
          is_private: is_private,
          coming_soon: coming_soon
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

  def full?(date)
    reservations_count(date) >= MAX_CAPACITY
  end

  def spots_left(date)
    MAX_CAPACITY - reservations_count(date)
  end

  def waitlist(date)
    user_session_waitlists.by_date(date).sorted
  end

  def invalid_date?(date)
    no_session_for_date = if recurring.empty?
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

  private

  def remove_orphan_sessions
    return unless saved_change_to_recurring? || saved_change_to_end_time?

    RemoveOrphanSessions.call(session: self)
  end
end
