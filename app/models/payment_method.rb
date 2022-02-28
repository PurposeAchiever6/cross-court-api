# == Schema Information
#
# Table name: payment_methods
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
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

  has_many :subscriptions
  has_one :active_subscription,
          -> { active.recent },
          class_name: 'Subscription',
          inverse_of: :payment_method

  validates :default, uniqueness: { scope: :user_id }, if: :default
  validates :user_id, :stripe_id, presence: true

  scope :sorted, -> { order(created_at: :desc) }
end
