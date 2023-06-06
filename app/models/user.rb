# == Schema Information
#
# Table name: users
#
#  id                                      :integer          not null, primary key
#  email                                   :string
#  encrypted_password                      :string           default(""), not null
#  reset_password_token                    :string
#  reset_password_sent_at                  :datetime
#  allow_password_change                   :boolean          default(FALSE)
#  remember_created_at                     :datetime
#  sign_in_count                           :integer          default(0), not null
#  current_sign_in_at                      :datetime
#  last_sign_in_at                         :datetime
#  current_sign_in_ip                      :inet
#  last_sign_in_ip                         :inet
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  provider                                :string           default("email"), not null
#  uid                                     :string           default(""), not null
#  tokens                                  :json
#  confirmation_token                      :string
#  confirmed_at                            :datetime
#  confirmation_sent_at                    :datetime
#  phone_number                            :string
#  credits                                 :integer          default(0), not null
#  is_referee                              :boolean          default(FALSE), not null
#  is_sem                                  :boolean          default(FALSE), not null
#  stripe_id                               :string
#  free_session_state                      :integer          default("not_claimed"), not null
#  free_session_payment_intent             :string
#  first_name                              :string           default(""), not null
#  last_name                               :string           default(""), not null
#  zipcode                                 :string
#  free_session_expiration_date            :date
#  referral_code                           :string
#  subscription_credits                    :integer          default(0), not null
#  skill_rating                            :decimal(2, 1)
#  drop_in_expiration_date                 :date
#  private_access                          :boolean          default(FALSE)
#  active_campaign_id                      :integer
#  birthday                                :date
#  cc_cash                                 :decimal(, )      default(0.0)
#  reserve_team                            :boolean          default(FALSE)
#  instagram_username                      :string
#  first_time_subscription_credits_used_at :datetime
#  subscription_skill_session_credits      :integer          default(0)
#  flagged                                 :boolean          default(FALSE)
#  is_coach                                :boolean          default(FALSE), not null
#  gender                                  :integer
#  bio                                     :string
#  credits_without_expiration              :integer          default(0)
#  scouting_credits                        :integer          default(0)
#  weight                                  :integer
#  height                                  :integer
#  competitive_basketball_activity         :string
#  current_basketball_activity             :string
#  position                                :string
#  goals                                   :string           is an Array
#  main_goal                               :string
#  apply_cc_cash_to_subscription           :boolean          default(FALSE)
#  signup_state                            :integer          default("created")
#  work_occupation                         :string
#  work_company                            :string
#  work_industry                           :string
#  links                                   :string           default([]), is an Array
#  utm_source                              :string
#  utm_medium                              :string
#  utm_campaign                            :string
#  utm_term                                :string
#  utm_content                             :string
#
# Indexes
#
#  index_users_on_confirmation_token            (confirmation_token) UNIQUE
#  index_users_on_drop_in_expiration_date       (drop_in_expiration_date)
#  index_users_on_email                         (email) UNIQUE
#  index_users_on_free_session_expiration_date  (free_session_expiration_date)
#  index_users_on_is_coach                      (is_coach)
#  index_users_on_is_referee                    (is_referee)
#  index_users_on_is_sem                        (is_sem)
#  index_users_on_phone_number                  (phone_number) UNIQUE
#  index_users_on_private_access                (private_access)
#  index_users_on_referral_code                 (referral_code) UNIQUE
#  index_users_on_reset_password_token          (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider              (uid,provider) UNIQUE
#  index_users_on_utm_campaign                  (utm_campaign)
#  index_users_on_utm_content                   (utm_content)
#  index_users_on_utm_medium                    (utm_medium)
#  index_users_on_utm_source                    (utm_source)
#  index_users_on_utm_term                      (utm_term)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include DeviseTokenAuth::Concerns::User

  FREE_SESSION_EXPIRATION_DAYS = 30.days.freeze
  DROP_IN_EXPIRATION_DAYS = 30.days.freeze

  has_paper_trail ignore: %i[sign_in_count
                             current_sign_in_at
                             last_sign_in_at
                             current_sign_in_ip
                             last_sign_in_ip
                             tokens]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  enum signup_state: {
    created: 0,
    personal_details: 1,
    completed: 2
  }, _prefix: true

  enum free_session_state: {
    not_claimed: 0,
    claimed: 1,
    used: 2,
    expired: 3,
    not_apply: 4
  }, _prefix: :free_session

  enum gender: {
    male: 0,
    female: 1,
    other: 2
  }, _prefix: true

  enum position: {
    point_guard: 'point_guard',
    shooting_guard: 'shooting_guard',
    small_forward: 'small_forward',
    power_forward: 'power_forward',
    center: 'center'
  }

  has_one :last_checked_in_user_session,
          -> { checked_in.order(date: :desc) },
          class_name: 'UserSession',
          inverse_of: :user,
          dependent: :destroy

  has_one :first_future_user_session,
          -> { future.reserved_or_confirmed.order(date: :asc, 'sessions.time' => :asc) },
          class_name: 'UserSession',
          inverse_of: :user,
          dependent: :destroy

  has_one :active_subscription,
          -> { active_or_paused.recent },
          class_name: 'Subscription',
          inverse_of: :user,
          dependent: :destroy

  has_one :default_payment_method,
          -> { where(default: true) },
          class_name: 'PaymentMethod',
          inverse_of: :user,
          dependent: :destroy

  has_one :referral_promo_code,
          class_name: 'PromoCode',
          dependent: :destroy,
          inverse_of: :user

  has_one :last_player_evaluation,
          -> { order(date: :desc, created_at: :desc) },
          class_name: 'PlayerEvaluation',
          inverse_of: :user,
          dependent: nil

  has_many :user_sessions, dependent: :destroy
  has_many :sem_sessions, dependent: :destroy
  has_many :referee_sessions, dependent: :destroy
  has_many :coach_sessions, dependent: :destroy
  has_many :sessions, through: :user_sessions
  has_many :payments, dependent: :nullify
  has_many :subscriptions, dependent: :destroy
  has_many :user_session_waitlists, dependent: :destroy
  has_many :payment_methods, dependent: :destroy
  has_many :player_evaluations, dependent: :destroy
  has_many :user_update_requests, dependent: :destroy
  has_many :late_arrivals, dependent: :destroy
  has_many :session_surveys, dependent: :nullify

  has_one_attached :image, dependent: :destroy

  validates :uid, uniqueness: { scope: :provider }
  validates :password, confirmation: true
  validates :credits, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :subscription_credits, presence: true, numericality: { only_integer: true }
  validates :subscription_skill_session_credits,
            presence: true,
            numericality: { only_integer: true }
  validates :free_session_state, presence: true
  validates :first_name,
            presence: true,
            unless: :signup_state_created?
  validates :last_name,
            presence: true,
            unless: :signup_state_created?
  validates :phone_number, uniqueness: true, allow_nil: true
  validates :phone_number,
            presence: true,
            unless: :signup_state_created?
  validates :zipcode,
            presence: true,
            length: { maximum: 5 },
            numericality: { only_integer: true },
            unless: :signup_state_created?
  validates :skill_rating,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 },
            allow_nil: true

  scope :referees, -> { where(is_referee: true) }
  scope :sems, -> { where(is_sem: true) }
  scope :coaches, -> { where(is_coach: true) }
  scope :no_credits, -> { where(credits: 0, subscription_credits: 0) }
  scope :sorted_by_full_name, -> { order('LOWER(first_name) ASC, LOWER(last_name) ASC') }
  scope :members, -> { joins(:active_subscription) }
  scope :reserve_team, -> { where(reserve_team: true) }
  scope :employees, -> { referees.or(sems).or(coaches) }

  before_validation :init_uid
  before_save :normalize_instagram_username
  after_update :update_external_records, :create_referral_code
  after_destroy :delete_stripe_customer,
                :delete_stripe_promo_code
  after_rollback :delete_stripe_customer, on: :create

  delegate :current_period_start,
           :current_period_end,
           :status,
           :cancel_at_period_end?,
           :cancel_at_next_period_end?,
           :will_pause?,
           :paused?,
           to: :active_subscription, prefix: true

  def self.from_social_provider(provider, user_params)
    where(provider:, uid: user_params['id']).first_or_create! do |user|
      user.password = Devise.friendly_token[0, 20]
      user.assign_attributes user_params.except('id')
    end
  end

  def links_raw
    links&.join(',')
  end

  def links_raw=(values)
    if values.blank?
      self.links = []
      return
    end

    new_links = values.split(',').map do |value|
      new_value = value.strip
      if new_value.starts_with?('http://') || new_value.starts_with?('https://')
        new_value
      else
        "https://#{new_value}"
      end
    end

    self.links = new_links
  end

  def employee?
    is_sem || is_referee || is_coach
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def credits?(amount = 1)
    credits >= amount \
      || credits_without_expiration >= amount \
        || subscription_credits >= amount \
          || unlimited_credits?
  end

  def unlimited_credits?
    subscription_credits == Product::UNLIMITED
  end

  def skill_session_credits?(amount = 1)
    subscription_skill_session_credits >= amount \
      || unlimited_skill_session_credits? \
        || credits?(amount)
  end

  def unlimited_skill_session_credits?
    subscription_skill_session_credits == Product::UNLIMITED
  end

  def scouting_credits?
    scouting_credits.positive?
  end

  def total_session_credits
    return '' if !credits || !credits_without_expiration || !subscription_credits

    unlimited_credits? ? 'Unlimited' : credits + credits_without_expiration + subscription_credits
  end

  def age
    return if birthday.blank?

    today = Time.zone.today

    birthday_month = birthday.month
    today_month = today.month

    age = today.year - birthday.year

    if today_month < birthday_month || (today_month == birthday_month && today.day < birthday.day)
      age -= 1
    end

    age
  end

  def first_timer?
    last_checked_in_user_session.blank?
  end

  def first_not_first_session?
    user_sessions.checked_in.not_first_sessions.count == 1
  end

  def membership
    active_subscription ? active_subscription.product.name : 'Not a member'
  end

  def free_jersey_rental?
    active_subscription&.product&.free_jersey_rental?
  end

  def free_towel_rental?
    active_subscription&.product&.free_towel_rental?
  end

  def received_free_session?
    !free_session_not_apply?
  end

  def give_free_session?
    Location.near(zipcode, :free_session_miles_radius).any?
  rescue SocketError, Timeout::Error, Geocoder::OverQueryLimitError, Geocoder::RequestDenied,
         Geocoder::InvalidRequest, Geocoder::InvalidApiKey, Geocoder::ServiceUnavailable => e
    Rollbar.error(e)
    true
  end

  def reserve_any_session?
    user_sessions.count != 0
  end

  def not_canceled_user_session?(session, date)
    user_sessions.reserved_or_confirmed.by_session(session).by_date(date).any?
  end

  def instagram_profile
    return if instagram_username.blank?

    "https://www.instagram.com/#{instagram_username[1..]}"
  end

  def never_been_a_member?
    subscriptions.count.zero?
  end

  def first_subscription?
    subscriptions.count == 1
  end

  def new_member?
    subscriptions.count == 1 &&
      (1.month.ago.beginning_of_day..Time.zone.today.end_of_day)
        .cover?(active_subscription&.created_at)
  end

  def formatted_height
    return unless height

    single_quote = '’'
    double_quote = '”'
    height_string = height.to_s

    "#{height_string.first}#{single_quote}#{height_string.last(2)}#{double_quote}"
  end

  private

  def password_required?
    false # overwrite devise requirement
  end

  def uses_email?
    provider == 'email' || email.present?
  end

  def init_uid
    self.uid = email if uid.blank? && provider == 'email'
  end

  def create_referral_code?
    !signup_state_created? && !referral_code
  end

  def create_referral_code
    return unless create_referral_code?

    referral_code = generate_referral_code
    update!(referral_code:)

    recurring_products = Product.recurring

    return if recurring_products.blank?

    promo_code_attrs = {
      type: PercentageDiscount.to_s,
      code: referral_code,
      discount: ENV.fetch('REFERRAL_CODE_PERCENTAGE_DISCOUNT', nil),
      use: 'referral',
      duration: :repeating,
      duration_in_months: 1,
      max_redemptions_by_user: 1,
      only_for_new_members: true,
      products: recurring_products
    }

    coupon_id = StripeService.create_coupon(promo_code_attrs, recurring_products).id
    promo_code_id = StripeService.create_promotion_code(coupon_id, promo_code_attrs).id

    create_referral_promo_code!(
      promo_code_attrs.merge(
        stripe_coupon_id: coupon_id,
        stripe_promo_code_id: promo_code_id
      )
    )
  end

  def generate_referral_code
    position = 0

    base_referral_code = "#{first_name}#{last_name}".gsub(/[^a-zA-Z0-9]/, '').upcase
    referral_code = base_referral_code

    loop do
      break unless User.find_by(referral_code:)

      referral_code = "#{base_referral_code}#{position + 1}"
      position += 1
    end

    referral_code
  end

  def update_external_records
    saved_changes_keys = saved_changes.keys

    if ActiveCampaignService::CONTACT_ATTRS.any? { |a| saved_changes_keys.include?(a) }
      ::ActiveCampaign::CreateUpdateContactJob.perform_later(id)
    end

    return unless SonarService::CUSTOMER_ATTRS.any? { |a| saved_changes_keys.include?(a) }

    ::Sonar::CreateUpdateCustomerJob.perform_later(id)
  end

  def delete_stripe_customer
    StripeService.delete_user(stripe_id) if stripe_id
  end

  def delete_stripe_promo_code
    StripeService.delete_coupon(referral_promo_code.stripe_coupon_id) if referral_promo_code
  end

  def normalize_instagram_username
    return if instagram_username.blank?

    username = instagram_username.starts_with?('@') ? instagram_username : "@#{instagram_username}"
    self.instagram_username = username.downcase
  end
end
