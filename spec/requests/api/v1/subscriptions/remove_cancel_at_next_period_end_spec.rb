require 'rails_helper'

describe 'POST api/v1/subscriptions/:id/remove_cancel_at_next_period_end' do
  let!(:user) { create(:user) }
  let!(:subscription) do
    create(:subscription, user:, mark_cancel_at_period_end_at:)
  end

  let(:mark_cancel_at_period_end_at) { Time.zone.today + 1.week }

  let(:request_headers) { auth_headers }
  let(:params) { {} }

  let(:response_body) { JSON.parse(subject.body).with_indifferent_access }

  before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

  subject do
    post remove_cancel_at_next_period_end_api_v1_subscription_path(subscription.id),
         headers: request_headers,
         params:,
         as: :json
    response
  end

  it { is_expected.to be_successful }

  it { expect(response_body[:subscription][:id]).to eq(subscription.id) }

  it 'updates mark_cancel_at_period_end_at to nil' do
    expect { subject }.to change {
      subscription.reload.mark_cancel_at_period_end_at
    }.from(mark_cancel_at_period_end_at).to(nil)
  end

  it 'calls Slack Service' do
    expect_any_instance_of(SlackService).to receive(
      :subscription_scheduled_cancellation_removed
    ).with(subscription)

    subject
  end

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }

    it { expect { subject }.not_to change { subscription.reload.mark_cancel_at_period_end_at } }
  end
end
