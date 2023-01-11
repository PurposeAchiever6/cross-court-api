require 'rails_helper'

describe 'GET api/v1/payments' do
  let(:user) { create(:user) }

  subject do
    get api_v1_payments_path, headers: auth_headers, as: :json
  end

  context 'when the user has no payments' do
    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns no payments' do
      expect(json[:payments].count).to eq(0)
    end
  end

  context 'when the user has payments' do
    let!(:payment) { create(:payment, user:) }

    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns payments' do
      expect(json[:payments].count).to eq(1)
    end

    context 'when the payment has a discount' do
      let!(:payment) { create(:payment, user:, amount: 100, discount: 20) }

      it 'returns the payment with the discount' do
        expect(json[:payments][0][:amount].to_i).to eq(100)
        expect(json[:payments][0][:discount].to_i).to eq(20)
      end
    end

    context 'when the payment was paid using cc_cash' do
      let!(:payment) { create(:payment, user:, amount: 100, cc_cash: 20) }

      it 'returns the payment with the discount' do
        expect(json[:payments][0][:amount].to_i).to eq(100)
        expect(json[:payments][0][:cc_cash].to_i).to eq(20)
      end
    end
  end
end
