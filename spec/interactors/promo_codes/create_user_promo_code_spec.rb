require 'rails_helper'

describe PromoCodes::CreateUserPromoCode do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:product) { create(:product, referral_cc_cash:) }
    let!(:promo_code) { create(:promo_code, use:, user: promo_code_user) }

    let(:referral_cc_cash) { rand(1..100).to_f }
    let(:promo_code_user) { nil }
    let(:use) { 'general' }

    subject do
      PromoCodes::CreateUserPromoCode.call(
        user:,
        promo_code:,
        product:
      )
    end

    it { expect { subject }.to change(UserPromoCode, :count).by(1) }

    it 'assigns the right user to the UserPromoCode' do
      subject
      expect(UserPromoCode.last.user).to eq(user)
    end

    it 'assigns the right promo code to the UserPromoCode' do
      subject
      expect(UserPromoCode.last.promo_code).to eq(promo_code)
    end

    it 'assigns the right times_used value to the UserPromoCode' do
      subject
      expect(UserPromoCode.last.times_used).to eq(1)
    end

    it 'does not enques ActiveCampaign::CreateDealJob' do
      expect { subject }.not_to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      )
    end

    context 'when the user had already used that promo code' do
      let!(:user_promo_code) { create(:user_promo_code, user:, promo_code:) }

      it { expect { subject }.not_to change(UserPromoCode, :count) }

      it { expect { subject }.to change { user_promo_code.reload.times_used }.from(1).to(2) }
    end

    context 'when the promo code is for referral' do
      let!(:promo_code_user) { create(:user, cc_cash:) }
      let(:use) { 'referral' }
      let(:cc_cash) { 0 }
      let(:referral_cash) { ['0', nil].sample }

      before { ENV['REFERRAL_CASH'] = referral_cash }

      it 'updates promo code user cc cash' do
        expect {
          subject
        }.to change { promo_code_user.reload.cc_cash }.from(0).to(referral_cc_cash)
      end

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::PROMO_CODE_REFERRAL_SUCCESS,
          promo_code_user.id,
          referred_id: user.id,
          cc_cash_awarded: referral_cc_cash.to_s
        )
      end

      it { expect { subject }.not_to change(ReferralCashPayment, :count) }

      context 'when promo code user already has some cc cash' do
        let(:cc_cash) { 15 }

        it 'sums the right value to promo code user cc cash' do
          expect {
            subject
          }.to change {
            promo_code_user.reload.cc_cash
          }.from(cc_cash).to(cc_cash + referral_cc_cash)
        end
      end

      context 'when product referral cc cash is zero' do
        let(:referral_cc_cash) { 0 }

        it { expect { subject }.not_to change { promo_code_user.reload.cc_cash } }
      end

      context 'when REFERRAL_CASH env var is positive' do
        let(:referral_cash) { rand(1..50).to_s }

        it { expect { subject }.to change(ReferralCashPayment, :count).by(1) }

        it 'creates a ReferralCashPayment with correct data' do
          subject
          expect(ReferralCashPayment.last.status).to eq('pending')
          expect(ReferralCashPayment.last.amount).to eq(referral_cash.to_i)
          expect(ReferralCashPayment.last.referral).to eq(promo_code_user)
          expect(ReferralCashPayment.last.referred).to eq(user)
          expect(ReferralCashPayment.last.user_promo_code).to eq(UserPromoCode.last)
        end
      end
    end
  end
end
