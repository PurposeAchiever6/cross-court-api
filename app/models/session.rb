# == Schema Information
#
# Table name: sessions
#
#  id                              :bigint           not null, primary key
#  start_time                      :date             not null
#  recurring                       :text
#  time                            :time             not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  location_id                     :bigint           not null
#  end_time                        :date
#  skill_level_id                  :bigint
#  is_private                      :boolean          default(FALSE)
#  coming_soon                     :boolean          default(FALSE)
#  is_open_club                    :boolean          default(FALSE)
#  duration_minutes                :integer          default(60)
#  deleted_at                      :datetime
#  max_first_timers                :integer
#  women_only                      :boolean          default(FALSE)
#  all_skill_levels_allowed        :boolean          default(TRUE)
#  max_capacity                    :integer          default(15)
#  skill_session                   :boolean          default(FALSE)
#  cc_cash_earned                  :decimal(, )      default(0.0)
#  default_referee_id              :integer
#  default_sem_id                  :integer
#  default_coach_id                :integer
#  guests_allowed                  :integer
#  guests_allowed_per_user         :integer
#  members_only                    :boolean          default(FALSE)
#  theme_title                     :string
#  theme_subheading                :string
#  theme_description               :text
#  cost_credits                    :integer          default(1)
#  allow_back_to_back_reservations :boolean          default(TRUE)
#  allow_auto_enable_guests        :boolean          default(FALSE)
#
# Indexes
#
#  index_sessions_on_default_coach_id    (default_coach_id)
#  index_sessions_on_default_referee_id  (default_referee_id)
#  index_sessions_on_default_sem_id      (default_sem_id)
#  index_sessions_on_deleted_at          (deleted_at)
#  index_sessions_on_location_id         (location_id)
#  index_sessions_on_skill_level_id      (skill_level_id)
#  index_sessions_on_start_time          (start_time)
#

class Session < ApplicationRecord
  DATE_FORMAT = '%d-%m-%Y'.freeze
  YEAR_MONTH_DAY = '%Y-%m-%d'.freeze
  MONTH_NAME_FORMAT = '%B, %d %Y'.freeze
  DAY_MONTH_NAME_FORMAT = '%A %B %-e'.freeze
  TIME_FORMAT = '%l:%M %P'.freeze
  QUERY_TIME_FORMAT = 'HH24:MI'.freeze
  RESERVATIONS_LIMIT_FOR_NO_CHARGE = ENV['RESERVATIONS_LIMIT_FOR_NO_CHARGE'].to_i
  CANCELLATION_PERIOD = ENV['CANCELLATION_PERIOD'].to_i.hours.freeze
  BACK_TO_BACK_TOLERANCE_MINUTES = ENV['BACK_TO_BACK_TOLERANCE_MINUTES'].to_i.minutes.freeze
  BACK_TO_BACK_RESERVATION_WINDOW_MINUTES = ENV['BACK_TO_BACK_RESERVATION_WINDOW_MINUTES'].to_i
                                                                                          .minutes
                                                                                          .freeze
  BACK_TO_BACK_MAX_RESERVATIONS_TO_DISABLE = ENV['BACK_TO_BACK_MAX_RESERVATIONS_TO_DISABLE'].to_i
                                                                                            .freeze

  acts_as_paranoid
  has_paper_trail

  serialize :recurring, Hash

  belongs_to :location, -> { with_deleted }, inverse_of: :sessions
  belongs_to :skill_level, optional: true
  belongs_to :default_referee, class_name: 'User', optional: true
  belongs_to :default_sem, class_name: 'User', optional: true
  belongs_to :default_coach, class_name: 'User', optional: true

  has_many :user_sessions
  has_many :referee_sessions
  has_many :sem_sessions
  has_many :coach_sessions
  has_many :user_session_waitlists
  has_many :user_session_votes
  has_many :users, through: :user_sessions
  has_many :session_exceptions, dependent: :destroy
  has_many :session_guests, through: :user_sessions
  has_many :shooting_machines,
           -> { order(:start_time, :end_time) },
           dependent: :destroy,
           inverse_of: :session
  has_many :session_allowed_products, dependent: :destroy
  has_many :products, through: :session_allowed_products

  validates :skill_level, presence: true, unless: -> { skill_session? || open_club? }
  validates :start_time, :time, :duration_minutes, presence: true
  validates :max_capacity, presence: true, if: -> { !open_club? }
  validates :cc_cash_earned, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :end_time,
            absence: { message: 'must be blank if session is not recurring' },
            if: -> { single_occurrence? }

  delegate :name,
           :description,
           :time_zone,
           :allowed_late_arrivals,
           :late_arrival_minutes,
           :late_arrival_fee,
           :sklz_late_arrival_fee,
           to: :location,
           prefix: true
  delegate :address, :time_zone, to: :location
  delegate :name, to: :skill_level, prefix: true, allow_nil: true
  delegate :max_sessions_booked_per_day,
           :max_skill_sessions_booked_per_day, to: :location, prefix: true

  accepts_nested_attributes_for :session_exceptions, allow_destroy: true
  accepts_nested_attributes_for :shooting_machines, allow_destroy: true

  after_update :remove_orphan_sessions
  before_destroy :check_for_future_user_sessions

  alias_attribute :open_club?, :is_open_club

  scope :visible_for, ->(user) { where(is_private: false) unless user&.private_access }
  scope :not_open_club, -> { where(is_open_club: false) }
  scope :not_skill_sessions, -> { where(skill_session: false) }
  scope :not_private, -> { where(is_private: false) }
  scope :not_coming_soon, -> { where(coming_soon: false) }
  scope :normal_sessions, -> { not_open_club.not_skill_sessions }
  scope :eligible_for_free_booking, -> { not_open_club.not_coming_soon.not_private }

  scope :for_range, (lambda do |start_date, end_date|
    where('start_time >= ? AND start_time <= ?', start_date, end_date)
      .or(where.not(recurring: nil))
  end)

  scope :by_location, (lambda do |location_id|
    location_id.blank? ? all : where(location_id:)
  end)

  scope :in_next_minutes, (lambda do |minutes|
    # rubocop:disable Layout/LineLength
    joins(:location).where(
      'to_char(time, :time_format) ' \
      'BETWEEN to_char(current_timestamp at time zone locations.time_zone, :time_format) AND ' \
      "to_char((current_timestamp + interval ':minutes minutes') at time zone locations.time_zone, :time_format)",
      minutes:,
      time_format: 'HH24MI'
    )
    # rubocop:enable Layout/LineLength
  end)

  scope :in_hours, (lambda do |hours|
    joins(:location).where(
      "to_char(current_timestamp at time zone locations.time_zone, :time_format) =
       to_char(time - interval ':hours hour', :time_format)",
      hours:,
      time_format: 'HH24'
    )
  end)

  def normal_session?
    !skill_session? && !is_open_club?
  end

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
      [self]
    else
      schedule.occurrences_between(start_date, end_date).map do |date|
        attributes = self.attributes.symbolize_keys.merge(start_time: date)

        attributes[:location] = location if association_cached?(:location)
        attributes[:skill_level] = skill_level if association_cached?(:skill_level)
        attributes[:products] = products if association_cached?(:products)

        Session.new(attributes).tap do |instance|
          # These new session instances should behave like persisted records so we can
          # use the `has_many through` relationships.
          instance.instance_variable_set('@new_record', false)
        end
      end
    end
  end

  def referee(date)
    referee_sessions.find_by(date:)&.referee
  end

  def sem(date)
    sem_sessions.find_by(date:)&.sem
  end

  def coach(date)
    coach_sessions.find_by(date:)&.coach
  end

  def reservations_count(date)
    not_canceled_reservations(date).count + guests_count(date)
  end

  def not_canceled_reservations(date)
    user_sessions.reserved_or_confirmed.by_date(date)
  end

  def waitlist_count(date)
    user_session_waitlists.by_date(date).pending.count
  end

  def on_waitlist?(date, user)
    waitlist(date).pending.by_user(user).exists?
  end

  def waitlist_placement(date, user)
    waitlist_index = waitlist(date).pending.map(&:user_id).index(user.id)

    return unless waitlist_index

    waitlist_index + 1
  end

  def first_timer_reservations(date, user_sessions = nil)
    reservations = user_sessions || not_canceled_reservations(date)

    ActiveRecord::Associations::Preloader.new(
      records: reservations,
      associations: { user: :last_checked_in_user_session }
    ).call

    reservations.select { |reservation| reservation.user.first_timer? }
  end

  def full?(date, user = nil)
    return false if open_club?

    reservations = not_canceled_reservations(date)
    session_max_capacity = reservations.length + guests_count(date) >= max_capacity

    return true if session_max_capacity
    return false unless max_first_timers && user&.first_timer?

    first_timer_reservations = first_timer_reservations(date, reservations)
    first_timer_reservations.length >= max_first_timers
  end

  def spots_left(date)
    return if open_club?

    total_spots_left = max_capacity - reservations_count(date)

    total_spots_left.positive? ? total_spots_left : 0
  end

  def waitlist(date)
    user_session_waitlists.by_date(date).sorted
  end

  def guests(date)
    session_guests.by_date(date)
  end

  def not_canceled_guests(date)
    guests(date).not_canceled
  end

  def guests_count(date)
    not_canceled_guests(date).count
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
    user_skill_rating = user.skill_rating

    return true if !skill_level || !user_skill_rating || all_skill_levels_allowed

    user_skill_rating >= skill_level.min && user_skill_rating <= skill_level.max
  end

  def reserve_team_reservation_allowed?(date)
    return false if open_club? || past?(date)

    return true if women_only || is_private

    reservations_count(date) < (ENV['RESERVE_TEAM_RESERVATIONS_LIMIT'] || '13').to_i
  end

  def max_capacity
    return if open_club?

    self[:max_capacity]
  end

  def user_reached_book_limit?(user, date)
    return false if open_club?

    if skill_session
      return false unless location_max_skill_sessions_booked_per_day

      booked_sessions = user.user_sessions.skill_sessions.reserved_or_confirmed.by_date(date).count
      booked_sessions >= location_max_skill_sessions_booked_per_day
    else
      return false unless location_max_sessions_booked_per_day

      booked_sessions = user.user_sessions
                            .normal_sessions
                            .reserved_or_confirmed
                            .by_date(date)
                            .count

      booked_sessions >= location_max_sessions_booked_per_day
    end
  end

  def guests_allowed?
    guests_allowed&.positive?
  end

  def shooting_machines?
    open_club?
  end

  def allowed_for_member?(user)
    return true unless members_only?

    return false unless user.active_subscription

    return true if session_allowed_products.empty?

    session_allowed_products.pluck(:product_id).include?(user.active_subscription.product_id)
  end

  def back_to_back_sessions(date)
    today_sessions = Session.includes(:session_exceptions)
                            .by_location(location)
                            .for_range(date, date)
                            .flat_map do |session_event|
                              session_event.calendar_events(date, date)
                            end

    today_sessions.filter do |session|
      next if session.id == id

      start_time = time
      end_time = start_time + duration_minutes.minutes

      current_start_time = session.time
      current_end_time = current_start_time + session.duration_minutes.minutes

      current_end_time.between?(start_time - BACK_TO_BACK_TOLERANCE_MINUTES, start_time) \
        || current_start_time.between?(end_time, end_time + BACK_TO_BACK_TOLERANCE_MINUTES)
    end
  end

  def back_to_back_restricted?(date, user)
    return false if !user || allow_back_to_back_reservations?(date)

    back_to_back_sessions(date).any? do |back_to_back_session|
      not_allowed_back_to_back = !back_to_back_session.allow_back_to_back_reservations
      user_reserved_back_to_back = user.not_canceled_user_session?(back_to_back_session, date)

      not_allowed_back_to_back && user_reserved_back_to_back
    end
  end

  def allow_back_to_back_reservations?(date)
    return true if allow_back_to_back_reservations

    back_to_back_allowed_reservations_count?(date) && back_to_back_allowed_time?(date)
  end

  def back_to_back_allowed_reservations_count?(date)
    reservations_count(date) <= BACK_TO_BACK_MAX_RESERVATIONS_TO_DISABLE
  end

  def back_to_back_allowed_time?(date)
    remaining_time(date) < BACK_TO_BACK_RESERVATION_WINDOW_MINUTES
  end

  def late_arrival_fee
    return 0 if open_club?

    skill_session? ? location_sklz_late_arrival_fee : location_late_arrival_fee
  end

  def eligible_for_free_booking?
    !open_club? && !is_private && !coming_soon
  end

  def allow_free_booking?(date, user)
    user_subscription_product = user&.active_subscription&.product

    return false unless user_subscription_product

    eligible_for_free_booking? \
      && user_subscription_product.no_booking_charge_feature \
        && remaining_time(date) < user_subscription_product.no_booking_charge_feature_hours.hours \
          && reservations_count(date) <= RESERVATIONS_LIMIT_FOR_NO_CHARGE
  end

  def frontend_details_url(date)
    front_end_url = ENV.fetch('FRONTENT_URL', nil)
    formatted_date = date.strftime(Session::YEAR_MONTH_DAY)
    "#{front_end_url}/session/#{id}/#{formatted_date}"
  end

  def experience_name
    return 'Office Hours' if is_open_club

    return 'SKLZ Session' if skill_session

    'Session'
  end

  private

  def remaining_time(date)
    current_time = Time.zone.local_to_utc(Time.current.in_time_zone(time_zone))
    session_time = "#{date} #{time}".to_datetime
    session_time.to_i - current_time.to_i
  end

  def remove_orphan_sessions
    return unless saved_change_to_recurring? || saved_change_to_end_time?

    RemoveOrphanSessions.call(session: self)
  end

  def check_for_future_user_sessions
    if user_sessions.future.reserved_or_confirmed.exists?
      errors.add(:base, 'The session has future user sessions reservations')
      throw(:abort)
    else
      referee_sessions.future.destroy_all
      sem_sessions.future.destroy_all
    end
  end
end
