require 'rails_helper'

describe 'GET api/v1/products' do
  subject { get api_v1_products_path, as: :json }

  context 'when there are no products' do
    before { subject }

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns no products' do
      expect(json[:products].count).to eq(0)
    end
  end

  context 'when there are some products' do
    let!(:products) { create_list(:product, 2) }

    before { subject }

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns the products' do
      expect(json[:products].count).to eq(2)
    end
  end
end
