require 'rails_helper'

describe 'GET api/v1/promo_code' do
  let(:user)       { create(:user) }
  let(:product)    { create(:product, price: price) }
  let(:promo_code) do
    create(
      :promo_code,
      discount: 10,
      products: [promo_product],
      expiration_date: expiration_date,
      max_redemptions: max_redemptions,
      max_redemptions_by_user: max_redemptions_by_user,
      times_used: times_used,
      for_referral: for_referral,
      user: promo_code_user
    )
  end

  let(:code) { promo_code.code }
  let(:promo_product) { product }
  let(:expiration_date) { nil }
  let(:max_redemptions) { nil }
  let(:max_redemptions_by_user) { nil }
  let(:times_used) { 0 }
  let(:for_referral) { false }
  let(:promo_code_user) { nil }
  let(:price) { 100 }

  let(:params) { { promo_code: code, product_id: product.id } }

  subject { get api_v1_promo_code_path, params: params, headers: auth_headers, as: :json }

  it 'returns the price with the promo code applied' do
    subject
    expect(json[:price].to_i).to eq(promo_code.apply_discount(price))
  end

  context "when the promo code doesn't exists" do
    let(:code) { '12345678' }

    it 'returns promo code invalid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.invalid'))
    end
  end

  context 'when the promo code is for another product' do
    let(:promo_product) { create(:product) }

    it 'returns promo code invalid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.invalid'))
    end
  end

  context 'when the promo code has expired' do
    let!(:expiration_date) { Date.yesterday }

    it 'returns promo code no longer valid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.no_longer_valid'))
    end
  end

  context 'when the promo code has been used more than max_redemptions' do
    let(:max_redemptions) { 2 }
    let(:times_used) { 2 }

    it 'returns promo code no longer valid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.no_longer_valid'))
    end
  end

  context 'when the promo code has already been used for that user' do
    let(:user_times_used) { 1 }
    let(:max_redemptions_by_user) { 1 }
    let!(:user_promo_code) do
      UserPromoCode.create!(user: user, promo_code: promo_code, times_used: user_times_used)
    end

    it 'returns promo code already used error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.already_used'))
    end

    context 'when it can be used more than once' do
      let(:max_redemptions_by_user) { 2 }

      it 'returns the price with the promo code applied' do
        subject
        expect(json[:price].to_i).to eq(promo_code.apply_discount(price))
      end
    end
  end

  context 'when promo code is for referral' do
    let!(:promo_code_user) { create(:user) }
    let(:for_referral) { true }

    it 'returns the price with the promo_code applied' do
      subject
      expect(json[:price].to_i).to eq(promo_code.apply_discount(price))
    end

    context 'when owner of the promo code is the current user' do
      let(:promo_code_user) { user }

      it 'returns promo code own usage error message' do
        subject
        expect(json[:error]).to eq(I18n.t('api.errors.promo_code.own_usage'))
      end
    end

    context 'when user is not a new member of crosscourt' do
      let!(:subscription) { create(:subscription, user: user) }

      it 'returns promo code no first subscription message' do
        subject
        expect(json[:error]).to eq(I18n.t('api.errors.promo_code.no_first_subscription'))
      end
    end
  end
end
