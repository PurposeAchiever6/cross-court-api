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

require 'rails_helper'

describe User do
  describe 'validations' do
    subject { build :user }

    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive.scoped_to(:provider) }
    it { is_expected.to validate_numericality_of(:credits).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:free_session_state) }
    it { is_expected.to validate_presence_of(:zipcode) }

    it 'defines free session states' do
      is_expected.to define_enum_for(
        :free_session_state
      ).with_values(%i[not_claimed claimed used expired not_apply]).with_prefix(:free_session)
    end
  end

  describe '#create' do
    let(:email) { 'email@sample.com' }
    let(:user_params) { { email: } }

    subject { User.create!(user_params) }

    it { expect(subject.persisted?).to eq(true) }
    it { expect(subject.signup_state).to eq('created') }

    context 'when a failure occurs and needs to rollback' do
      let(:stripe_id) { 'stripe-id' }
      let(:user_params) { { email:, stripe_id: } }

      subject do
        ActiveRecord::Base.transaction do
          User.create!(user_params)
          raise 'error'
        end
      end

      it 'calls Stripe for deleting customer' do
        expect(Stripe::Customer).to receive(:delete)
        subject rescue nil
      end

      context 'when user does not have a stripe id associated' do
        let(:stripe_id) { nil }

        it 'does not call Stripe for deleting customer' do
          expect(Stripe::Customer).not_to receive(:delete)
          subject rescue nil
        end
      end
    end
  end

  describe '#update' do
    let!(:user) { create(:user, referral_code:) }

    let!(:referral_code) { nil }
    let(:first_name) { 'John' }
    let(:last_name) { 'Travolta' }
    let(:update_params) { { first_name:, last_name: } }

    subject { user.update(update_params) }

    it { expect { subject }.to change { user.reload.referral_code }.to('JOHNTRAVOLTA') }

    it { expect { subject }.not_to change(PromoCode, :count) }

    it 'enques ActiveCampaign CreateUpdateContactJob' do
      expect {
        subject
      }.to have_enqueued_job(::ActiveCampaign::CreateUpdateContactJob).on_queue('default')
    end

    it 'enques Sonar CreateUpdateCustomerJob' do
      expect {
        subject
      }.to have_enqueued_job(::Sonar::CreateUpdateCustomerJob).on_queue('default')
    end

    context 'when user already has a referral_code' do
      let!(:referral_code) { 'REFERRALCODE' }

      it { expect { subject }.not_to change { user.reload.referral_code } }
    end

    context 'when already exists a user with same referral_code' do
      before { create(:user, referral_code: 'JOHNTRAVOLTA') }

      it { expect { subject }.to change { user.reload.referral_code }.to('JOHNTRAVOLTA1') }

      context 'when exists another user with same referral_code' do
        before { create(:user, referral_code: 'JOHNTRAVOLTA1') }

        it { expect { subject }.to change { user.reload.referral_code }.to('JOHNTRAVOLTA2') }
      end
    end

    context 'when exists at least one recurring product in the system' do
      let!(:product) { create(:product, product_type: :recurring) }

      it { expect { subject }.to change(PromoCode, :count).by(1) }

      it 'Creates the referral promo code with right data' do
        subject
        expect(PromoCode.last.use).to eq('referral')
        expect(PromoCode.last.code).to eq('JOHNTRAVOLTA')
        expect(PromoCode.last.only_for_new_members).to eq(true)
      end
    end
  end

  describe '#destroy' do
    let(:stripe_coupon_id) { 'stripe-coupon-id' }
    let(:stripe_customer_id) { 'stripe-customer-id' }
    let!(:user) { create(:user, stripe_id: stripe_customer_id) }
    let!(:promo_code) do
      create(:promo_code, use: 'referral', user:, stripe_coupon_id:)
    end

    before do
      StripeMocker.new.delete_customer(stripe_customer_id)
      StripeMocker.new.delete_coupon(stripe_coupon_id)
    end

    subject { user.destroy }

    it { expect { subject }.to change(PromoCode, :count).by(-1) }

    it 'calls Stripe for deleting customer' do
      expect(Stripe::Customer).to receive(:delete).with(stripe_customer_id)
      subject
    end

    it 'calls Stripe for deleting coupon' do
      expect(Stripe::Coupon).to receive(:delete).with(stripe_coupon_id)
      subject
    end
  end

  describe '#first_not_first_session?' do
    let(:user) { create(:user) }

    subject { user.first_not_first_session? }

    context 'when it has only one user_session' do
      before { create(:user_session, user:, first_session: true, checked_in: true) }

      it { is_expected.to eq(false) }
    end

    context 'when it has multiple user_sessions' do
      before do
        create(:user_session, user:, first_session: true, checked_in: true)
        create(:user_session, user:, first_session: false, checked_in: true)
        create(:user_session, user:, first_session: false, checked_in: true)
        create(:user_session, user:, first_session: false, checked_in: true)
      end

      it { is_expected.to eq(false) }
    end

    context 'when is has two user_session' do
      before do
        create(:user_session, user:, first_session: true, checked_in: true)
        create(:user_session, user:, first_session: false, checked_in: true)
      end

      it { is_expected.to eq(true) }
    end
  end

  describe '#generate_referral_code' do
    let(:user) { build(:user, first_name:, last_name:) }
    let(:first_name) { 'Elon' }
    let(:last_name) { 'Musk' }

    subject { user.send(:generate_referral_code) }

    it { is_expected.to eq('ELONMUSK') }

    context 'when already exists a user with the same referral_code' do
      let!(:other_user) { create(:user, referral_code: 'ELONMUSK') }

      it { is_expected.to eq('ELONMUSK1') }

      context 'when already exists multiple users with consecutive referral_codes' do
        5.times do |i|
          let!("user_#{i + 1}") { create(:user, referral_code: "ELONMUSK#{i + 1}") }
        end

        it { is_expected.to eq('ELONMUSK6') }
      end
    end
  end
end
