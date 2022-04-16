require 'rails_helper'

describe 'GET api/v1/user/referrals' do
  let!(:user) { create(:user) }
  let!(:referral_promo_code) { create(:promo_code, for_referral: true, user: user) }
  let!(:user_promo_codes) do
    create_list(:user_promo_code, amount_referrals, promo_code: referral_promo_code)
  end

  let(:amount_referrals) { rand(1..10) }
  let(:request_headers) { auth_headers }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    get referrals_api_v1_user_path, headers: request_headers, params: {}, as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect(response_body[:referrals].length).to eq(amount_referrals) }

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(UserSessionWaitlist, :count) }
  end

  context 'when the referrals are for another user' do
    let!(:another_user) { create(:user) }
    let!(:referral_promo_code) { create(:promo_code, for_referral: true, user: another_user) }

    it { is_expected.to be_successful }
    it { expect(response_body[:referrals]).to eq([]) }
  end
end
