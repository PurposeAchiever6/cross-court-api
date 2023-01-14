# == Schema Information
#
# Table name: payments
#
#  id              :bigint           not null, primary key
#  user_id         :bigint
#  amount          :decimal(10, 2)   not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :string           not null
#  discount        :decimal(10, 2)   default(0.0)
#  last_4          :string
#  stripe_id       :string
#  status          :integer          default("success")
#  error_message   :string
#  cc_cash         :decimal(10, 2)   default(0.0)
#  chargeable_type :string
#  chargeable_id   :bigint
#
# Indexes
#
#  index_payments_on_chargeable_type_and_chargeable_id  (chargeable_type,chargeable_id)
#  index_payments_on_status                             (status)
#  index_payments_on_user_id                            (user_id)
#

FactoryBot.define do
  factory :payment do
    user
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    description { Faker::Lorem.word }

    transient do
      chargeable { nil }
    end

    chargeable_id { chargeable&.id }
    chargeable_type { chargeable&.to_s }
  end
end
