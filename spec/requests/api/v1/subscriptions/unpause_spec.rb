require 'rails_helper'

describe 'PUT api/v1/subscriptions/:id/unpause' do
  let!(:user) { create(:user) }
  let!(:status) { 'paused' }
  let!(:subscription) { create(:subscription, user:, status:) }
  let!(:subscription_pause) do
    create(:subscription_pause, subscription:, status: :finished)
  end
  let(:stripe_invoice_id) { 'il_1Kooo9EbKIwsJiGZ9Ip7Efqr' }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    put unpause_api_v1_subscription_path(subscription),
        params: {},
        headers: auth_headers,
        as: :json
    response
  end

  before do
    allow_any_instance_of(Slack::Notifier).to receive(:ping)
    StripeMocker.new.unpause_subscription(subscription.stripe_id)
    StripeMocker.new.retrieve_invoice(user.stripe_id, stripe_invoice_id)
  end

  it { is_expected.to be_successful }

  it 'calls Subscriptions::UnpauseSubscription' do
    expect(Subscriptions::UnpauseSubscription).to receive(:call).with(
      { subscription: }
    )

    subject rescue nil
  end

  it 'calls Slack Service' do
    expect_any_instance_of(SlackService).to receive(:subscription_unpaused)
    subject
  end

  context 'when the subscription is not paused' do
    let!(:status) { 'active' }

    it { is_expected.to have_http_status(:bad_request) }

    it { expect(response_body[:error]).to eq('The subscription is not paused') }
  end
end
