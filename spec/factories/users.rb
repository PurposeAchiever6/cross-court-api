# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  allow_password_change  :boolean          default(FALSE)
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  tokens                 :json
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  name                   :string           default("")
#  phone_number           :string
#  credits                :integer          default(0), not null
#  product_id             :integer
#  stripe_id              :string
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_product_id            (product_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_stripe_id             (stripe_id)
#  index_users_on_uid_and_provider      (uid,provider) UNIQUE
#

FactoryBot.define do
  factory :user do
    email    { Faker::Internet.unique.email }
    password { Faker::Internet.password(8) }
    name     { Faker::Name.name }
    uid      { Faker::Number.unique.number(10) }

    trait :confirmed do
      confirmed_at { Time.current }
    end
  end
end
