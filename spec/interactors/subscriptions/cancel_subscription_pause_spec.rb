require 'rails_helper'

describe Subscriptions::CancelSubscriptionPause do
  describe '.call' do
    let(:subscription_status) { 'paused' }
    let!(:subscription) { create(:subscription, status: subscription_status) }
    let!(:subscription_pause) { create(:subscription_pause, subscription: subscription) }

    before do
      allow_any_instance_of(
        Sidekiq::ScheduledSet
      ).to receive(:find_job).and_return(OpenStruct.new(delete: true))
    end

    subject { described_class.call(subscription: subscription) }

    it 'updates subscription_pause status' do
      expect { subject }.to change {
        subscription_pause.reload.status
      }.from('upcoming').to('canceled')
    end

    it 'updates subscription_pause canceled_at' do
      expect { subject }.to change {
        subscription_pause.reload.canceled_at
      }.from(nil).to(anything)
    end
  end
end
