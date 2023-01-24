require 'rails_helper'

describe 'GET api/v1/products' do
  let(:user) { create(:user, reserve_team:) }
  let(:reserve_team) { false }
  let(:headers) { {} }

  subject { get api_v1_products_path, headers:, as: :json }

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
    let!(:product1) { create(:product, order_number: 2, product_type: 'one_time') }
    let!(:product2) { create(:product, order_number: 3, product_type: 'recurring') }
    let!(:product3) { create(:product, order_number: 1, product_type: 'recurring') }
    let!(:product4) { create(:product, order_number: 0, available_for: 'reserve_team') }

    before { subject }

    it 'returns success' do
      expect(response).to be_successful
    end

    context 'when the user is not logged in' do
      it 'returns the products for everyone' do
        expect(json[:products].count).to eq(3)
      end
    end

    context 'when the user is logged in' do
      let(:headers) { auth_headers }

      context 'when the user is from the reserve team' do
        let(:reserve_team) { true }

        it 'returns the products for the reserve team & the drop-in' do
          expect(json[:products].count).to eq(2)
        end
      end

      context 'when the user is not from the reserve team' do
        it 'returns the products for everyone' do
          expect(json[:products].count).to eq(3)
        end
      end
    end
  end
end
