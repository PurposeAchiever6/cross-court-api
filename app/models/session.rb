# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  start_time  :date             not null
#  recurring   :text
#  time        :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer          not null
#  end_time    :date
#  level       :integer          default(0), not null
#
# Indexes
#
#  index_sessions_on_location_id  (location_id)
#

class Session < ApplicationRecord
  DATE_FORMAT = '%d-%m-%Y'.freeze
  TIME_FORMAT = '%H:%M'.freeze
  QUERY_TIME_FORMAT = 'HH24:MI'.freeze
  CANCELLATION_PERIOD = ENV['CANCELLATION_PERIOD'].to_i.hours.freeze
  MAX_CAPACITY = ENV['MAX_CAPACITY'].to_i.freeze

  enum level: { basic: 0, advanced: 1 }

  attr_accessor :employees_assigned

  serialize :recurring, Hash

  belongs_to :location, with_deleted: true
  has_many :user_sessions, dependent: :destroy
  has_many :users, through: :user_sessions
  has_many :session_exceptions, dependent: :destroy
  has_many :referee_sessions, dependent: :nullify
  has_many :sem_sessions, dependent: :nullify

  validates :start_time, :time, presence: true

  delegate :name, to: :location, prefix: true
  delegate :direction, :time_zone, to: :location

  accepts_nested_attributes_for :session_exceptions, allow_destroy: true

  after_update :remove_orphan_sessions

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
          level: level
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

  def full?(date)
    user_sessions.visible_for_player.by_date(date).count == MAX_CAPACITY
  end

  private

  def remove_orphan_sessions
    return unless saved_change_to_recurring? || saved_change_to_end_time?

    RemoveOrphanSessions.call(session: self)
  end
end
