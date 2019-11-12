# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  start_time  :date             not null
#  recurring   :text
#  time        :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer          not null
#
# Indexes
#
#  index_sessions_on_location_id  (location_id)
#

class Session < ApplicationRecord
  serialize :recurring, Hash

  belongs_to :location

  validates :name, :start_time, :time, presence: true

  delegate :name, to: :location, prefix: true

  scope :for_range, (lambda do |start_date, end_date|
    where('start_time > ? AND start_time < ?', start_date, end_date)
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

  def schedule(start)
    schedule = IceCube::Schedule.new(start)
    schedule.add_recurrence_rule(rule)
    schedule
  end

  def calendar_events(start_date, end_date)
    if recurring.empty?
      [self]
    else
      schedule(start_date).occurrences(end_date).map do |date|
        Session.new(id: id, name: name, start_time: date)
      end
    end
  end
end
