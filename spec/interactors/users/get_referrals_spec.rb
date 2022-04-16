require 'rails_helper'

describe Users::GetReferrals do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:referral_promo_code) { create(:promo_code, for_referral: true, user: user) }
    let!(:user_promo_codes) do
      create_list(:user_promo_code, amount_referrals, promo_code: referral_promo_code)
    end

    let(:amount_referrals) { rand(1..10) }

    subject { Users::GetReferrals.call(user: user) }

    it { expect(subject.success?).to eq(true) }
    it { expect(subject.list).to match_array(user_promo_codes) }
    it { expect(subject.list.length).to eq(amount_referrals) }

    context 'when the referrals are for another user' do
      let!(:another_user) { create(:user) }
      let!(:referral_promo_code) { create(:promo_code, for_referral: true, user: another_user) }

      it { expect(subject.success?).to eq(true) }
      it { expect(subject.list).to eq([]) }
    end
  end
end
