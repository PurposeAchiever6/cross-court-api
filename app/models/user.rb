# == Schema Information
#
# Table name: users
#
#  id                           :integer          not null, primary key
#  email                        :string
#  encrypted_password           :string           default(""), not null
#  reset_password_token         :string
#  reset_password_sent_at       :datetime
#  allow_password_change        :boolean          default(FALSE)
#  remember_created_at          :datetime
#  sign_in_count                :integer          default(0), not null
#  current_sign_in_at           :datetime
#  last_sign_in_at              :datetime
#  current_sign_in_ip           :inet
#  last_sign_in_ip              :inet
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  provider                     :string           default("email"), not null
#  uid                          :string           default(""), not null
#  tokens                       :json
#  confirmation_token           :string
#  confirmed_at                 :datetime
#  confirmation_sent_at         :datetime
#  phone_number                 :string
#  credits                      :integer          default(0), not null
#  is_referee                   :boolean          default(FALSE), not null
#  is_sem                       :boolean          default(FALSE), not null
#  stripe_id                    :string
#  free_session_state           :integer          default("not_claimed"), not null
#  free_session_payment_intent  :string
#  first_name                   :string           default(""), not null
#  last_name                    :string           default(""), not null
#  zipcode                      :string
#  free_session_expiration_date :date
#  referral_code                :string
#  subscription_credits         :integer          default(0), not null
#  skill_rating                 :decimal(2, 1)
#  drop_in_expiration_date      :date
#  vaccinated                   :boolean          default(FALSE)
#  private_access               :boolean          default(FALSE)
#  active_campaign_id           :integer
#  birthday                     :date
#
# Indexes
#
#  index_users_on_confirmation_token            (confirmation_token) UNIQUE
#  index_users_on_drop_in_expiration_date       (drop_in_expiration_date)
#  index_users_on_email                         (email) UNIQUE
#  index_users_on_free_session_expiration_date  (free_session_expiration_date)
#  index_users_on_is_referee                    (is_referee)
#  index_users_on_is_sem                        (is_sem)
#  index_users_on_private_access                (private_access)
#  index_users_on_referral_code                 (referral_code) UNIQUE
#  index_users_on_reset_password_token          (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider              (uid,provider) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include DeviseTokenAuth::Concerns::User

  FREE_SESSION_EXPIRATION_DAYS = 30.days.freeze
  DROP_IN_EXPIRATION_DAYS = 30.days.freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  enum free_session_state: { not_claimed: 0, claimed: 1, used: 2, expired: 3 },
       _prefix: :free_session

  has_one :last_checked_in_user_session,
          -> { checked_in.order(date: :desc) },
          class_name: 'UserSession',
          inverse_of: :user

  has_one :first_future_user_session,
          -> { future.not_canceled.order(date: :asc, 'sessions.time' => :asc) },
          class_name: 'UserSession',
          inverse_of: :user

  has_one :active_subscription,
          -> { active.recent },
          class_name: 'Subscription',
          inverse_of: :user

  has_one :default_payment_method,
          -> { where(default: true) },
          class_name: 'PaymentMethod',
          inverse_of: :user

  has_one :referral_promo_code,
          class_name: 'PromoCode',
          dependent: :nullify,
          inverse_of: :user

  has_many :user_sessions, dependent: :destroy
  has_many :sem_sessions, dependent: :destroy
  has_many :referee_sessions, dependent: :destroy
  has_many :sessions, through: :user_sessions
  has_many :purchases, dependent: :nullify
  has_many :subscriptions, dependent: :destroy
  has_many :user_session_waitlists, dependent: :destroy
  has_many :payment_methods, dependent: :destroy

  has_one_attached :image, dependent: :destroy

  validates :uid, uniqueness: { scope: :provider }
  validates :credits, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :free_session_state, presence: true
  validates :zipcode, presence: true, length: { maximum: 5 }, numericality: { only_integer: true }
  validates :phone_number, uniqueness: true
  validates :skill_rating,
            numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 7 },
            allow_nil: true
  validates :birthday, presence: true, on: :create

  scope :referees, -> { where(is_referee: true) }
  scope :sems, -> { where(is_sem: true) }
  scope :no_credits, -> { where(credits: 0, subscription_credits: 0) }
  scope :sorted_by_full_name, -> { order('LOWER(first_name) ASC, LOWER(last_name) ASC') }

  before_validation :init_uid
  after_create :create_referral_code
  after_commit :update_external_records, on: [:update]
  after_destroy :delete_stripe_customer

  delegate :current_period_start, :current_period_end, :status, :cancel_at_period_end,
           to: :active_subscription, prefix: true

  def self.from_social_provider(provider, user_params)
    where(provider: provider, uid: user_params['id']).first_or_create! do |user|
      user.password = Devise.friendly_token[0, 20]
      user.assign_attributes user_params.except('id')
    end
  end

  def employee?
    is_sem || is_referee
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def credits?
    credits.positive? || subscription_credits.positive? || unlimited_credits?
  end

  def unlimited_credits?
    subscription_credits == Product::UNLIMITED
  end

  def total_credits
    unlimited_credits? ? 'Unlimited' : credits + subscription_credits
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

  def first_not_free_session?
    user_sessions.checked_in.not_free_sessions.count == 1
  end

  def membership
    active_subscription ? active_subscription.product.name : 'Not a member'
  end

  private

  def uses_email?
    provider == 'email' || email.present?
  end

  def init_uid
    self.uid = email if uid.blank? && provider == 'email'
  end

  def create_referral_code
    referral_code = generate_referral_code
    update!(referral_code: referral_code)

    recurring_products = Product.recurring

    return if recurring_products.blank?

    promo_code_attrs = {
      type: PercentageDiscount.to_s,
      code: referral_code,
      discount: 50,
      for_referral: true,
      duration: :repeating,
      duration_in_months: 1,
      max_redemptions_by_user: 1,
      products: recurring_products,
      user: self
    }

    coupon_id = StripeService.create_coupon(promo_code_attrs, recurring_products).id
    promo_code_id = StripeService.create_promotion_code(coupon_id, promo_code_attrs).id

    PromoCode.create!(
      promo_code_attrs.merge(
        stripe_coupon_id: coupon_id,
        stripe_promo_code_id: promo_code_id
      )
    )
  end

  def generate_referral_code
    position = User.where(
      'lower(first_name) = ? AND lower(last_name) = ?',
      first_name.downcase,
      last_name.downcase
    ).count

    referral_code = "#{first_name}#{last_name}".gsub(/\s+/, '')
    referral_code += (position - 1).to_s if position > 1

    referral_code.upcase
  end

  def update_external_records
    saved_changes_keys = saved_changes.keys
    return unless persisted?

    if ActiveCampaignService::CONTACT_ATTRS.any? { |a| saved_changes_keys.include?(a) }
      ::ActiveCampaign::CreateUpdateContactJob.perform_later(id)
    end

    return unless SonarService::CUSTOMER_ATTRS.any? { |a| saved_changes_keys.include?(a) }

    ::Sonar::CreateUpdateCustomerJob.perform_later(id)
  end

  def delete_stripe_customer
    StripeService.delete_user(self)
  end
end
