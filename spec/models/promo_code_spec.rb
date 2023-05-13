# == Schema Information
#
# Table name: promo_codes
#
#  id                           :bigint           not null, primary key
#  discount                     :integer          default(0), not null
#  code                         :string           not null
#  type                         :string           not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  expiration_date              :date
#  stripe_promo_code_id         :string
#  stripe_coupon_id             :string
#  duration                     :string
#  duration_in_months           :integer
#  max_redemptions              :integer
#  max_redemptions_by_user      :integer
#  times_used                   :integer          default(0)
#  user_id                      :bigint
#  user_max_checked_in_sessions :integer
#  use                          :string           default("general")
#  only_for_new_members         :boolean          default(FALSE)
#
# Indexes
#
#  index_promo_codes_on_code     (code) UNIQUE
#  index_promo_codes_on_use      (use)
#  index_promo_codes_on_user_id  (user_id)
#

require 'rails_helper'

describe UserPromoCode do
  let!(:user) { create(:user) }
  let!(:product) { create(:product) }

  let(:expiration_date) { nil }
  let(:max_redemptions) { nil }
  let(:max_redemptions_by_user) { nil }
  let(:user_max_checked_in_sessions) { nil }
  let(:times_used) { 0 }
  let(:use) { 'general' }
  let(:promo_code_user) { nil }
  let(:only_for_new_members) { false }

  let(:promo_code) do
    create(
      :promo_code,
      products: [product],
      expiration_date:,
      max_redemptions:,
      max_redemptions_by_user:,
      user_max_checked_in_sessions:,
      times_used:,
      use:,
      user: promo_code_user,
      only_for_new_members:
    )
  end

  describe 'still_valid?' do
    subject { promo_code.still_valid?(user, product) }

    it { is_expected.to eq(true) }

    context 'when is for another product' do
      let!(:another_product) { create(:product) }

      before { promo_code.update!(products: [another_product]) }

      it { is_expected.to eq(false) }
    end

    context 'when is expired' do
      let(:expiration_date) { 2.days.ago }

      it { is_expected.to eq(false) }
    end

    context 'when has been used' do
      let(:max_redemptions) { 5 }
      let(:times_used) { 5 }

      it { is_expected.to eq(false) }
    end

    context 'when has been used for the user' do
      let(:max_redemptions) { 5 }
      let(:max_redemptions_by_user) { 2 }
      let(:user_times_used) { 2 }
      let(:times_used) { 2 }

      let!(:user_promo_code) do
        create(:user_promo_code, promo_code:, user:, times_used: user_times_used)
      end

      it { is_expected.to eq(false) }

      context 'is valid for another user' do
        let!(:another_user) { create(:user) }

        subject { promo_code.still_valid?(another_user, product) }

        it { is_expected.to eq(true) }
      end
    end

    context 'when promo code is for referral' do
      let!(:promo_code_user) { create(:user) }
      let(:use) { 'referral' }

      it { is_expected.to eq(true) }

      context 'when owner of the promo code is the current user' do
        let(:promo_code_user) { user }

        it { is_expected.to eq(false) }
      end
    end

    context 'when promo code has a restriction on user checked in sessions' do
      let(:user_max_checked_in_sessions) { 0 }

      it { is_expected.to eq(true) }

      context 'when user has already attended to a session' do
        let!(:user_session) { create(:user_session, user:, checked_in: true) }

        it { is_expected.to eq(false) }
      end
    end

    context 'when promo code is only valid for new members' do
      let(:only_for_new_members) { true }

      it { is_expected.to eq(true) }

      context 'when user is a member' do
        let!(:subscription) { create(:subscription, user:) }

        it { is_expected.to eq(false) }

        context 'when the user is not a member but has been' do
          let!(:subscription) { create(:subscription, user:, status: :canceled) }

          it { is_expected.to eq(false) }
        end
      end
    end
  end
end
