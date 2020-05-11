# == Schema Information
#
# Table name: user_promo_codes
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  promo_code_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_user_promo_codes_on_promo_code_id  (promo_code_id)
#  index_user_promo_codes_on_user_id        (user_id)
#

FactoryBot.define do
  factory :user_promo_code do
    user
    promo_code
  end
end
