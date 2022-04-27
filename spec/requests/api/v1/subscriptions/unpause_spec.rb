require 'rails_helper'

describe 'PUT api/v1/subscriptions/:id/unpause' do
  let!(:user) { create(:user) }
  let!(:status) { 'paused' }
  let!(:subscription) { create(:subscription, user: user, status: status) }
  let!(:subscription_pause) { create(:subscription_pause, subscription: subscription) }

  subject do
    put unpause_api_v1_subscription_path(subscription), params: {}, headers: auth_headers, as: :json
  end

  before { StripeMocker.new.unpause_subscription(subscription.stripe_id) }

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it 'calls Subscriptions::UnpauseSubscription' do
    expect(Subscriptions::UnpauseSubscription).to receive(:call).with(subscription: subscription)

    subject rescue nil
  end

  context 'when the subscription is not paused' do
    let!(:status) { 'active' }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end
end
