require 'rails_helper'

describe 'GET api/v1/promo_code' do
  let(:user)       { create(:user) }
  let(:product)    { create(:product, price: 100) }
  let(:promo_code) do
    create(
      :promo_code,
      discount: 10,
      products: [promo_product],
      expiration_date: expiration_date,
      max_redemptions: max_redemptions,
      max_redemptions_by_user: max_redemptions_by_user,
      times_used: times_used
    )
  end

  let(:code) { promo_code.code }
  let(:promo_product) { product }
  let(:expiration_date) { nil }
  let(:max_redemptions) { nil }
  let(:max_redemptions_by_user) { nil }
  let(:times_used) { 0 }
  let(:price) { 100 }

  let(:params) { { promo_code: code, product_id: product.id } }

  subject { get api_v1_promo_code_path, params: params, headers: auth_headers, as: :json }

  it 'returns the price with the promo_code applied' do
    subject
    expect(json[:price].to_i).to eq(promo_code.apply_discount(price))
  end

  context "when the promo_code doesn't exists" do
    let(:code) { '12345678' }

    it 'returns promo_code invalid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.invalid'))
    end
  end

  context 'when the promo code is for another product' do
    let(:promo_product) { create(:product) }

    it 'returns promo_code invalid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.invalid'))
    end
  end

  context 'when the promo code has expired' do
    let!(:expiration_date) { Date.yesterday }

    it 'returns promo_code no longer valid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.no_longer_valid'))
    end
  end

  context 'when the promo code has been used more than max_redemptions' do
    let(:max_redemptions) { 2 }
    let(:times_used) { 2 }

    it 'returns promo_code no longer valid error message' do
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

    it 'returns promo_code already used error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.already_used'))
    end

    context 'when it can be used more than once' do
      let(:max_redemptions_by_user) { 2 }

      it 'returns the price with the promo_code applied' do
        subject
        expect(json[:price].to_i).to eq(promo_code.apply_discount(price))
      end
    end
  end
end
