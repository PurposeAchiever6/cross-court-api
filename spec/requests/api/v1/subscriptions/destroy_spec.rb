require 'rails_helper'

describe 'DELETE api/v1/subscriptions/:id' do
  let(:user) { create(:user) }
  let(:subscription_status) { :active }
  let(:subscription) { create(:subscription, status: subscription_status, user: user) }

  let(:stripe_response) do
    {
      id: subscription.stripe_id,
      items: double(data: [double(id: subscription.stripe_item_id)]),
      status: 'canceled',
      current_period_start: subscription.current_period_start,
      current_period_end: subscription.current_period_end,
      cancel_at: subscription.cancel_at,
      canceled_at: Time.current.to_i,
      cancel_at_period_end: subscription.cancel_at_period_end
    }
  end

  before do
    allow(StripeService).to receive(:cancel_subscription).and_return(double(stripe_response))
    allow_any_instance_of(SlackService).to receive(:subscription_canceled)
    allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
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

  it 'sets the subscription status to canceled' do
    expect { subject }.to change { subscription.reload.status }.to('canceled')
  end

  it 'calls the slack service' do
    expect_any_instance_of(SlackService).to receive(:subscription_canceled).with(subscription)
    subject
  end

  it 'calls the klaviyo service' do
    expect_any_instance_of(KlaviyoService).to receive(:event)
    subject
  end

  context 'when the subscription is not active' do
    let(:subscription_status) { %i[past_due canceled].sample }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end
end
