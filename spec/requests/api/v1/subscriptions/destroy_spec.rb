require 'rails_helper'

describe 'DELETE api/v1/subscriptions/:id' do
  let(:user) { create(:user) }
  let(:cancel_at_period_end) { false }
  let(:subscription) do
    create(
      :subscription,
      user:,
      cancel_at_period_end:
    )
  end

  let(:stripe_response) do
    {
      id: subscription.stripe_id,
      items: double(data: [double(id: subscription.stripe_item_id)]),
      status: 'active',
      current_period_start: subscription.current_period_start,
      current_period_end: subscription.current_period_end,
      cancel_at: subscription.cancel_at,
      canceled_at: Time.current.to_i,
      cancel_at_period_end: true,
      pause_collection: nil
    }
  end

  before do
    allow(StripeService).to receive(
      :cancel_subscription_at_period_end
    ).and_return(double(stripe_response))
    allow_any_instance_of(SlackService).to receive(:subscription_canceled)
    ActiveCampaignMocker.new.mock
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

  it 'does not change the subscription credits of the user' do
    expect { subject }.not_to change { user.reload.subscription_credits }
  end

  it 'does not change the subscription status' do
    expect { subject }.not_to change { subscription.reload.status }
  end

  it 'changes the subscription cancel_at_period_end to true' do
    expect { subject }.to change { subscription.reload.cancel_at_period_end }.from(false).to(true)
  end

  it 'calls the slack service' do
    expect_any_instance_of(SlackService).to receive(:subscription_canceled).with(subscription)
    subject
  end

  it 'calls the Active Campaign service' do
    expect { subject }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default')
  end

  context 'when the subscription is already canceled at period end' do
    let(:cancel_at_period_end) { true }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end
end
