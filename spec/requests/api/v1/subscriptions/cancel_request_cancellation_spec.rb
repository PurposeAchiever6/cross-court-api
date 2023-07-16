require 'rails_helper'

describe 'POST api/v1/subscriptions/cancel_request_cancellation' do
  let!(:user) { create(:user) }
  let!(:subscription_cancellation_request) do
    create(
      :subscription_cancellation_request,
      user:,
      status:
    )
  end

  let(:subscription) { subscription_cancellation_request.user.active_subscription }
  let(:status) { :pending }

  let(:request_headers) { auth_headers }
  let(:params) { {} }

  let(:response_body) { JSON.parse(subject.body).with_indifferent_access }

  subject do
    post cancel_request_cancellation_api_v1_subscriptions_path,
         headers: request_headers,
         params:,
         as: :json
    response
  end

  it { is_expected.to be_successful }

  it { expect(response_body[:subscription][:id]).to eq(subscription.id) }

  it 'updates subscription_cancellation_request status' do
    expect {
      subject
    }.to change { subscription_cancellation_request.reload.status }.to('cancel_by_user')
  end

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }

    it { expect { subject }.not_to change { subscription_cancellation_request.reload.status } }
  end
end
