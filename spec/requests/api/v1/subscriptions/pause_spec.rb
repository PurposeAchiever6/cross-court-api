require 'rails_helper'

describe 'PUT api/v1/subscriptions/:id/pause' do
  let!(:user) { create(:user) }
  let!(:status) { 'active' }
  let!(:subscription) { create(:subscription, user: user, status: status) }
  let(:months) { [1, 2].sample.to_s }
  let(:params) { { months: months } }
  let(:resumes_at) { subscription.current_period_end - 1.day + months.to_i.months }

  subject do
    put pause_api_v1_subscription_path(subscription),
        params: params, headers: auth_headers, as: :json
  end

  before { StripeMocker.new.pause_subscription(subscription.stripe_id) }

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it 'calls Subscriptions::UnpauseSubscription' do
    expect(Subscriptions::PauseSubscription).to receive(:call).with(
      subscription: subscription,
      months: months
    )

    subject rescue nil
  end

  it 'enques ::Subscriptions::PauseJob' do
    expect { subject }.to have_enqueued_job(
      ::Subscriptions::PauseJob
    ).with(
      subscription.id,
      resumes_at.to_i
    )
  end

  context 'when the subscription is not active' do
    let!(:status) { 'paused' }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when months are not correct' do
    let(:months) { 3 }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when months are not correct' do
    let(:months) { 3 }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end

  context 'when no more pauses are available' do
    before do
      ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE'] = '2'
      create_list(:subscription_pause, 2, subscription: subscription)
    end

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end
end
