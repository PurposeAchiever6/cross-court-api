require 'rails_helper'

describe 'GET api/v1/promo_code' do
  let(:user)       { create(:user) }
  let(:product)    { create(:product, price: 100) }
  let(:promo_code) { create(:promo_code, discount: 10, product: promo_product, expiration_date: expiration_date) }
  let(:code) { promo_code.code }
  let(:promo_product) { product }
  let(:expiration_date) { nil }
  let(:price)      { 100 }
  let(:params)     { { promo_code: code, product_id: product.id } }

  subject { get api_v1_promo_code_path, params: params, headers: auth_headers, as: :json }

  context 'when the promo_code exists' do
    it 'returns the price with the promo_code applied' do
      subject
      expect(json[:price].to_i).to eq(promo_code.apply_discount(price))
    end
  end

  context "when the promo_code doesn't exists" do
    let(:code) { '12345678' }

    it 'returns promo_code invalid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.invalid'))
    end
  end

  context 'when the promo code has expired' do
    let!(:expiration_date) { Date.yesterday }

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

  context 'when the promo code has already been used' do
    let!(:user_promo_code) { UserPromoCode.create!(user: user, promo_code: promo_code) }

    it 'returns promo_code invalid error message' do
      subject
      expect(json[:error]).to eq(I18n.t('api.errors.promo_code.already_used'))
    end
  end
end
