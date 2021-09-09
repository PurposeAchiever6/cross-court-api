require 'rails_helper'

describe 'GET api/v1/subscriptions' do
  let(:user) { create(:user) }

  subject do
    get api_v1_subscriptions_path, headers: auth_headers, as: :json
  end

  context 'when the user has no subscriptions' do
    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns no subscriptions' do
      expect(json[:subscriptions].count).to eq(0)
    end
  end

  context 'when the user has subscriptions' do
    let!(:subscription) { create(:subscription, user: user) }

    before do
      subject
    end

    it 'returns success' do
      expect(response).to be_successful
    end

    it 'returns subscriptions' do
      expect(json[:subscriptions].count).to eq(1)
    end
  end
end
