# == Schema Information
#
# Table name: payment_methods
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  stripe_id  :string
#  brand      :string
#  exp_month  :integer
#  exp_year   :integer
#  last_4     :string
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payment_methods_on_user_id  (user_id)
#

class PaymentMethod < ApplicationRecord
  belongs_to :user

  has_many :subscriptions, dependent: :nullify
  has_one :active_subscription,
          -> { active_or_paused.recent },
          class_name: 'Subscription',
          inverse_of: :payment_method,
          dependent: nil

  validates :default, uniqueness: { scope: :user_id }, if: :default
  validates :stripe_id, presence: true

  scope :sorted, -> { order(created_at: :desc) }
end
