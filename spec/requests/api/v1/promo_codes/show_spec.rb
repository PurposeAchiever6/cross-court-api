require 'rails_helper'

describe 'GET api/v1/promo_code' do
  let(:promo_code) { create(:promo_code, discount: 10) }
  let(:price)      { 100 }
  let(:params)     { { promo_code: code, price: price } }

  subject { get api_v1_promo_code_path, params: params, as: :json }

  context "when the promo_code doesn't exists" do
    let(:code) { '12345678' }

    it 'raises an exception' do
      subject
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when the promo_code exists' do
    let(:code) { promo_code.code }

    it 'returns the price with the promo_code applied' do
      subject
      expect(json[:price]).to eq(promo_code.apply_discount(price))
    end
  end
end
