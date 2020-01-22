module EmployeeSession
  extend ActiveSupport::Concern

  included do
    SESSION_DURATION = ENV['SESSION_DURATION'].to_i.minutes.freeze
    START_LEAD_TIME = ENV['START_LEAD_TIME'].to_i.minutes.freeze

    belongs_to :user
    belongs_to :session, optional: true

    validates :date, presence: true

    delegate :time, :time_zone, to: :session

    after_validation :destroy_previous_assignment

    scope :future, (lambda do
      joins(session: :location)
        .where('date >= (current_timestamp at time zone locations.time_zone)::date')
    end)

    def in_start_time?
      today = Date.current.in_time_zone(time_zone).to_date
      current_time = Time.current.in_time_zone(time_zone).strftime(Session::TIME_FORMAT)
      start_time = (time - START_LEAD_TIME).strftime(Session::TIME_FORMAT)
      max_start_time = (time + SESSION_DURATION).strftime(Session::TIME_FORMAT)
      today == date && current_time.between?(start_time, max_start_time)
    end

    private

    def destroy_previous_assignment
      self.class.where(session_id: session_id, date: date).where.not(id: id).destroy_all
    end
  end
end
