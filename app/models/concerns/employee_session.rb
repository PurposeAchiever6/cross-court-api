module EmployeeSession
  extend ActiveSupport::Concern

  included do
    SESSION_DURATION = ENV['SESSION_DURATION'].to_i.minutes.freeze
    START_LEAD_TIME = ENV['START_LEAD_TIME'].to_i.hours.freeze

    enum state: { unconfirmed: 0, canceled: 1, confirmed: 2 }

    belongs_to :user
    belongs_to :session, optional: true

    validates :date, presence: true
    delegate :time, :time_zone, :location, to: :session
    after_validation :destroy_previous_assignment

    scope :future, (lambda do
      joins(session: :location)
        .where('date >= (current_timestamp at time zone locations.time_zone)::date')
    end)

    scope :ordered_by_date, -> { order(:date) }

    def in_start_time?
      current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
      start_time = datetime - START_LEAD_TIME
      max_start_time = datetime + SESSION_DURATION

      current_time.between?(start_time, max_start_time)
    end

    private

    def destroy_previous_assignment
      self.class.where(session_id: session_id, date: date).where.not(id: id).destroy_all
    end

    def datetime
      DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)
    end
  end
end
