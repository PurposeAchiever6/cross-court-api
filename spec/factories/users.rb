# == Schema Information
#
# Table name: users
#
#  id                                      :integer          not null, primary key
#  email                                   :string
#  encrypted_password                      :string           default(""), not null
#  reset_password_token                    :string
#  reset_password_sent_at                  :datetime
#  allow_password_change                   :boolean          default(FALSE)
#  remember_created_at                     :datetime
#  sign_in_count                           :integer          default(0), not null
#  current_sign_in_at                      :datetime
#  last_sign_in_at                         :datetime
#  current_sign_in_ip                      :inet
#  last_sign_in_ip                         :inet
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  provider                                :string           default("email"), not null
#  uid                                     :string           default(""), not null
#  tokens                                  :json
#  confirmation_token                      :string
#  confirmed_at                            :datetime
#  confirmation_sent_at                    :datetime
#  phone_number                            :string
#  credits                                 :integer          default(0), not null
#  is_referee                              :boolean          default(FALSE), not null
#  is_sem                                  :boolean          default(FALSE), not null
#  stripe_id                               :string
#  free_session_state                      :integer          default("not_claimed"), not null
#  free_session_payment_intent             :string
#  first_name                              :string           default(""), not null
#  last_name                               :string           default(""), not null
#  zipcode                                 :string
#  free_session_expiration_date            :date
#  referral_code                           :string
#  subscription_credits                    :integer          default(0), not null
#  skill_rating                            :decimal(2, 1)
#  drop_in_expiration_date                 :date
#  private_access                          :boolean          default(FALSE)
#  active_campaign_id                      :integer
#  birthday                                :date
#  cc_cash                                 :decimal(, )      default(0.0)
#  source                                  :string
#  reserve_team                            :boolean          default(FALSE)
#  instagram_username                      :string
#  first_time_subscription_credits_used_at :datetime
#  subscription_skill_session_credits      :integer          default(0)
#  flagged                                 :boolean          default(FALSE)
#  is_coach                                :boolean          default(FALSE), not null
#  gender                                  :integer
#  bio                                     :string
#  credits_without_expiration              :integer          default(0)
#  scouting_credits                        :integer          default(0)
#  weight                                  :integer
#  height                                  :integer
#  competitive_basketball_activity         :string
#  current_basketball_activity             :string
#  position                                :string
#  goals                                   :string           is an Array
#  main_goal                               :string
#  apply_cc_cash_to_subscription           :boolean          default(FALSE)
#  signup_state                            :integer          default("created")
#  work_occupation                         :string
#  work_company                            :string
#  work_industry                           :string
#  links                                   :string           default([]), is an Array
#
# Indexes
#
#  index_users_on_confirmation_token            (confirmation_token) UNIQUE
#  index_users_on_drop_in_expiration_date       (drop_in_expiration_date)
#  index_users_on_email                         (email) UNIQUE
#  index_users_on_free_session_expiration_date  (free_session_expiration_date)
#  index_users_on_is_coach                      (is_coach)
#  index_users_on_is_referee                    (is_referee)
#  index_users_on_is_sem                        (is_sem)
#  index_users_on_phone_number                  (phone_number) UNIQUE
#  index_users_on_private_access                (private_access)
#  index_users_on_referral_code                 (referral_code) UNIQUE
#  index_users_on_reset_password_token          (reset_password_token) UNIQUE
#  index_users_on_source                        (source)
#  index_users_on_uid_and_provider              (uid,provider) UNIQUE
#

FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 8) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    uid { Faker::Number.unique.number(digits: 10) }
    zipcode { Faker::Address.zip_code[0..4] }
    free_session_expiration_date { Time.zone.today + User::FREE_SESSION_EXPIRATION_DAYS }
    drop_in_expiration_date { Time.zone.today + User::FREE_SESSION_EXPIRATION_DAYS }
    phone_number { Faker::PhoneNumber.cell_phone }
    private_access { false }
    reserve_team { false }
    birthday { Time.zone.today - 20.years }
    skill_rating { rand(1..5) }
    stripe_id { 'cus_AJ6y81jMo1Na22' }
    cc_cash { 0 }
    first_time_subscription_credits_used_at { Time.zone.today - 1.month }
    flagged { false }
    gender { %i[male female].sample }
    scouting_credits { 0 }
    apply_cc_cash_to_subscription { false }
    signup_state { :completed }

    trait :confirmed do
      confirmed_at { Time.current }
      confirmation_sent_at { Time.zone.now }
      confirmation_token { SecureRandom.hex(10) }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :referee do
      is_referee { true }
    end

    trait :sem do
      is_sem { true }
    end

    trait :coach do
      is_coach { true }
    end

    trait :with_image do
      image { Rack::Test::UploadedFile.new('spec/fixtures/blank.png', 'image/png') }
    end

    trait :with_unlimited_subscription do
      subscription_credits { Product::UNLIMITED }
      active_subscription { create(:subscription, :with_unlimited_product) }
    end

    trait :not_first_timer do
      after :create do |user|
        create(:user_session, user:, checked_in: true)
      end
    end

    trait :with_payment_method do
      after :create do |user|
        create(:payment_method, user:, default: true)
      end
    end
  end
end
