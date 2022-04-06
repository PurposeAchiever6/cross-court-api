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
#  referral_code                :string
#  subscription_credits         :integer          default(0), not null
#  skill_rating                 :decimal(2, 1)
#  drop_in_expiration_date      :date
#  vaccinated                   :boolean          default(FALSE)
#  private_access               :boolean          default(FALSE)
#  active_campaign_id           :integer
#  birthday                     :date
#
# Indexes
#
#  index_users_on_confirmation_token            (confirmation_token) UNIQUE
#  index_users_on_drop_in_expiration_date       (drop_in_expiration_date)
#  index_users_on_email                         (email) UNIQUE
#  index_users_on_free_session_expiration_date  (free_session_expiration_date)
#  index_users_on_is_referee                    (is_referee)
#  index_users_on_is_sem                        (is_sem)
#  index_users_on_private_access                (private_access)
#  index_users_on_reset_password_token          (reset_password_token) UNIQUE
#  index_users_on_uid_and_provider              (uid,provider) UNIQUE
#

require 'rails_helper'

describe User do
  describe 'validations' do
    subject { build :user }
    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
    it { is_expected.to validate_numericality_of(:credits).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:free_session_state) }
    it 'defines free session states' do
      is_expected.to define_enum_for(
        :free_session_state
      ).with_values(%i[not_claimed claimed used expired]).with_prefix(:free_session)
    end
    it { is_expected.to validate_presence_of(:zipcode) }
    it { is_expected.to validate_presence_of(:birthday) }

    context 'when was created with regular login' do
      subject { build :user }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive.scoped_to(:provider) }
      it { is_expected.to validate_presence_of(:email) }
    end
  end

  context 'when updating any sonar or active campaign attribute' do
    let(:user) { create(:user) }

    subject { user.update(first_name: 'Other') }

    it do
      expect {
        subject
      }.to have_enqueued_job(::ActiveCampaign::CreateUpdateContactJob).on_queue('default')
    end

    it do
      expect { subject }.to have_enqueued_job(::Sonar::CreateUpdateCustomerJob).on_queue('default')
    end
  end

  describe '#first_not_free_session?' do
    let(:user) { create(:user) }
    subject { user.first_not_free_session? }

    context 'when it only has only one free user_session' do
      before { create(:user_session, user: user, is_free_session: true, checked_in: true) }

      it { is_expected.to eq(false) }
    end

    context 'when it has multiple user_sessions' do
      before do
        create(:user_session, user: user, is_free_session: true, checked_in: true)
        create(:user_session, user: user, is_free_session: false, checked_in: true)
        create(:user_session, user: user, is_free_session: false, checked_in: true)
        create(:user_session, user: user, is_free_session: false, checked_in: true)
      end

      it { is_expected.to eq(false) }
    end

    context 'when is not free first user_session' do
      before do
        create(:user_session, user: user, is_free_session: true, checked_in: true)
        create(:user_session, user: user, is_free_session: false, checked_in: true)
      end

      it { is_expected.to eq(true) }
    end
  end
end
