require 'rails_helper'

describe 'GET api/v1/purchases' do
  let(:user) { create(:user) }

  subject do
    get api_v1_purchases_path, headers: auth_headers, as: :json
  end

  context 'when the user has no purchases' do
    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns no purchases' do
      expect(json[:purchases].count).to eq(0)
    end
  end

  context 'when the user has purchases' do
    let!(:purchase) { create(:purchase, user: user) }

    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns purchases' do
      expect(json[:purchases].count).to eq(1)
    end

    context 'when the purchase has a discount' do
      let!(:purchase) { create(:purchase, user: user, price: 100, discount: 20) }

      it 'returns the purchase with the right value' do
        expect(json[:purchases][0][:price].to_i).to eq(80)
      end
    end
  end
end
