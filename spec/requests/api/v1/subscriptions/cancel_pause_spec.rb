require 'rails_helper'
require 'sidekiq/testing'

describe 'PUT api/v1/subscriptions/:id/cancel_pause' do
  let!(:user) { create(:user) }
  let!(:status) { 'paused' }
  let!(:subscription) { create(:subscription, user: user, status: status) }
  let!(:subscription_pause) { create(:subscription_pause, subscription: subscription) }

  subject do
    put cancel_pause_api_v1_subscription_path(subscription),
        params: {}, headers: auth_headers, as: :json
  end

  before do
    allow_any_instance_of(
      Sidekiq::ScheduledSet
    ).to receive(:find_job).and_return(OpenStruct.new(delete: true))
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it { expect { subject }.to change { subscription_pause.reload.status }.to('canceled') }
  it { expect { subject }.to change { subscription_pause.reload.canceled_at }.to(anything) }
end
