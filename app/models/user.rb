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
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_is_referee            (is_referee)
#  index_users_on_is_sem                (is_sem)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  include DeviseTokenAuth::Concerns::User

  FREE_SESSION_EXPIRATION_DAYS = 30.days.freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  enum free_session_state: { not_claimed: 0, claimed: 1, used: 2, expired: 3 }, _prefix: :free_session

  has_one :last_checked_in_user_session,
          -> { where(checked_in: true).order(date: :desc) },
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

  has_many :user_sessions, dependent: :destroy
  has_many :sem_sessions, dependent: :destroy
  has_many :referee_sessions, dependent: :destroy
  has_many :sessions, through: :user_sessions
  has_many :purchases, dependent: :nullify
  has_many :subscriptions, dependent: :destroy

  has_one_attached :image

  validates :uid, uniqueness: { scope: :provider }
  validates :credits, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :free_session_state, presence: true
  validates :zipcode, presence: true, length: { maximum: 5 }, numericality: { only_integer: true }
  validates :phone_number, uniqueness: true

  before_validation :init_uid

  scope :referees, -> { where(is_referee: true) }
  scope :sems, -> { where(is_sem: true) }
  scope :no_credits, -> { where(credits: 0) }

  after_create :create_referral_code

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

  def first_session?
    user_sessions.empty?
  end

  private

  def uses_email?
    provider == 'email' || email.present?
  end

  def init_uid
    self.uid = email if uid.blank? && provider == 'email'
  end

  def create_referral_code
    loop do
      code = SecureRandom.hex(8)
      next if User.where(referral_code: code).exists?

      self.referral_code = code
      save!
      break
    end
  end
end
