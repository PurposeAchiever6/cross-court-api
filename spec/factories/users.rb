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

FactoryBot.define do
  factory :user do
    email                       { Faker::Internet.unique.email }
    password                    { Faker::Internet.password(8) }
    first_name                  { Faker::Name.first_name }
    last_name                   { Faker::Name.last_name }
    uid                         { Faker::Number.unique.number(10) }
    zipcode                     { Faker::Address.zip_code[0..4] }
    free_session_expiration_date { Time.zone.today + User::FREE_SESSION_EXPIRATION_DAYS }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :referee do
      is_referee true
    end

    trait :sem do
      is_sem true
    end

    trait :with_image do
      image { Rack::Test::UploadedFile.new('spec/fixtures/blank.png', 'image/png') }
    end
  end
end