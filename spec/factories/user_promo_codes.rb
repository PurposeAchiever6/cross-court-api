# == Schema Information
#
# Table name: user_promo_codes
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  promo_code_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  times_used    :integer          default(0)
#
# Indexes
#
#  index_user_promo_codes_on_promo_code_id              (promo_code_id)
#  index_user_promo_codes_on_promo_code_id_and_user_id  (promo_code_id,user_id) UNIQUE
#  index_user_promo_codes_on_user_id                    (user_id)
#

FactoryBot.define do
  factory :user_promo_code do
    times_used { 1 }
    user
    promo_code
  end
end
