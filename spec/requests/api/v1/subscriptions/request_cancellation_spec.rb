require 'rails_helper'

describe 'POST api/v1/subscriptions/request_cancellation' do
  let!(:user) { create(:user) }
  let(:experience_rate) { rand(1..5) }
  let(:service_rate) { rand(1..5) }
  let(:recommend_rate) { rand(1..5) }
  let(:reason) { 'Too expensive!!!' }

  let(:request_headers) { auth_headers }
  let(:params) do
    {
      experiencie_rate: experience_rate,
      service_rate: service_rate,
      recommend_rate: recommend_rate,
      reason: reason
    }
  end

  before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

  let(:response_body) { subject.body }

  subject do
    post request_cancellation_api_v1_subscriptions_path,
         headers: request_headers,
         params: params,
         as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect { subject }.to change(SubscriptionCancellationRequest, :count).by(1) }
  it { expect(response_body).to be_empty }

  it 'calls Slack Service' do
    expect_any_instance_of(SlackService).to receive(:notify_subscription_cancellation_request)
    subject
  end

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(SubscriptionCancellationRequest, :count) }
  end
end
