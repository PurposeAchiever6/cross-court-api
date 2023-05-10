# == Schema Information
#
# Table name: promo_codes
#
#  id                           :bigint           not null, primary key
#  discount                     :integer          default(0), not null
#  code                         :string           not null
#  type                         :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  expiration_date              :date
#  stripe_promo_code_id         :string
#  stripe_coupon_id             :string
#  duration                     :string
#  duration_in_months           :integer
#  max_redemptions              :integer
#  max_redemptions_by_user      :integer
#  times_used                   :integer          default(0)
#  user_id                      :bigint
#  user_max_checked_in_sessions :integer
#  use                          :string           default("general")
#
# Indexes
#
#  index_promo_codes_on_code     (code) UNIQUE
#  index_promo_codes_on_use      (use)
#  index_promo_codes_on_user_id  (user_id)
#

class PromoCode < ApplicationRecord
  TYPES = %w[SpecificAmountDiscount PercentageDiscount].freeze

  has_paper_trail if: ->(promo_code) { promo_code.general? }

  belongs_to :user, optional: true

  has_one :product, dependent: :nullify

  has_many :user_promo_codes, dependent: :destroy
  has_many :products_promo_codes, dependent: :destroy
  has_many :products, through: :products_promo_codes

  validates :discount, :code, :type, presence: true
  validates :code, uniqueness: true
  validates :max_redemptions,
            numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :max_redemptions_by_user,
            numericality: { only_integer: true, greater_than: 0, allow_nil: true }
  validates :user_max_checked_in_sessions,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }
  validates :duration, presence: true, if: -> { products.any?(&:recurring?) }
  validates :duration_in_months, presence: true, if: -> { duration == 'repeating' }
  validates :discount,
            inclusion: { in: 1..100, message: 'needs to be between 1 and 100' },
            if: -> { percentage_discount? }
  validates :products, presence: true

  enum duration: {
    once: 'once',
    forever: 'forever',
    repeating: 'repeating'
  }

  enum use: {
    general: 'general',
    referral: 'referral',
    cc_cash: 'cc_cash'
  }

  scope :for_product, (lambda do |product|
    joins(:products_promo_codes).where(products_promo_codes: { product: })
  end)

  def to_s
    "#{code} (#{discount}#{percentage_discount? ? '% off' : '$ off'})"
  end

  def percentage_discount?
    type == PercentageDiscount.to_s
  end

  def amount_discount?
    type == SpecificAmountDiscount.to_s
  end

  def still_valid?(user, product)
    validate!(user, product)
    true
  rescue PromoCodeInvalidException
    false
  end

  def invalid?(user, product)
    !still_valid?(user, product)
  end

  def expired?
    expiration_date ? Time.current.to_date >= expiration_date : false
  end

  def max_times_used?
    return false if max_redemptions.nil?

    times_used >= max_redemptions
  end

  def max_times_used_by_user?(user)
    return false if max_redemptions_by_user.nil?

    user_promo_code_times_used = user_promo_codes.find_by(user:)&.times_used || 0

    user_promo_code_times_used >= max_redemptions_by_user
  end

  def max_checked_in_sessions_by_user?(user)
    return false if user_max_checked_in_sessions.nil?

    user_checked_ins = user.user_sessions.checked_in.count

    user_checked_ins > user_max_checked_in_sessions
  end

  def for_product?(product)
    products.any? { |current_product| current_product == product }
  end

  def validate!(user, product, from_admin = false)
    raise PromoCodeInvalidException unless for_product?(product)

    if expired? || max_times_used?
      raise PromoCodeInvalidException, I18n.t('api.errors.promo_code.no_longer_valid')
    end

    if max_times_used_by_user?(user)
      raise PromoCodeInvalidException, I18n.t('api.errors.promo_code.already_used')
    end

    if !from_admin && max_checked_in_sessions_by_user?(user)
      raise PromoCodeInvalidException, I18n.t(
        'api.errors.promo_code.max_checked_in_sessions',
        user_max_checked_in_sessions: (user_max_checked_in_sessions + 1).ordinalize
      )
    end

    if user == self.user
      raise PromoCodeInvalidException, I18n.t('api.errors.promo_code.own_usage')
    end

    if referral? && user.subscriptions.count.positive?
      raise PromoCodeInvalidException, I18n.t('api.errors.promo_code.no_first_subscription')
    end
  end
end
