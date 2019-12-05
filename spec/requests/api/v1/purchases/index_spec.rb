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
    let!(:purchases) { create_list(:purchase, 2, user: user) }

    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns purchases' do
      expect(json[:purchases].count).to eq(2)
    end
  end
end
