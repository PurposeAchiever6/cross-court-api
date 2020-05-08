# == Schema Information
#
# Table name: promo_codes
#
#  id              :integer          not null, primary key
#  discount        :integer          default(0), not null
#  code            :string           not null
#  type            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  expiration_date :date             not null
#
# Indexes
#
#  index_promo_codes_on_code  (code) UNIQUE
#

FactoryBot.define do
  factory :promo_code, class: SpecificAmountDiscount do
    discount        { Faker::Number.number(2) }
    code            { Faker::Lorem.word }
    expiration_date { 1.year.from_now }
  end
end
