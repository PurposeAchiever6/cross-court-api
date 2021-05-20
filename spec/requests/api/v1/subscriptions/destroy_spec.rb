require 'rails_helper'

describe 'DELETE api/v1/subscriptions/:id' do
  let(:user)           { create(:user) }
  let(:subscription)   { create(:subscription, user: user) }

  before do
    stub_request(:delete, %r{stripe.com/v1/subscriptions/#{subscription.stripe_id}})
      .to_return(status: 200, body: '{}')
  end

  subject do
    delete api_v1_subscription_path(subscription.id),
           headers: auth_headers,
           as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it 'resets the subscription credits of the user' do
    expect { subject }.to change { user.reload.subscription_credits }.from(subscription.product.credits).to(0)
  end
end
