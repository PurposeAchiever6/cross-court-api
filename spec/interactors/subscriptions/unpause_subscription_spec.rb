require 'rails_helper'

describe Subscriptions::UnpauseSubscription do
  describe '.call' do
    let(:subscription_status) { 'paused' }
    let!(:subscription) { create(:subscription, status: subscription_status) }
    let!(:subscription_pause) { create(:subscription_pause, subscription: subscription) }

    before do
      Timecop.freeze(Time.current)
      StripeMocker.new.unpause_subscription(subscription.stripe_id)
    end

    after do
      Timecop.return
    end

    subject { described_class.call(subscription: subscription) }

    it 'updates subscription status' do
      expect { subject }.to change {
        subscription.reload.status
      }.from(subscription_status).to('active')
    end

    it 'updates subscription_pause unpaused attr' do
      expect { subject }.to change {
        subscription_pause.reload.unpaused
      }.from(false).to(true)
    end

    it 'updates subscription_pause unpaused_at attr' do
      expect { subject }.to change {
        subscription_pause.reload.unpaused_at
      }.from(nil).to(anything)
    end

    context 'when the subscription is active' do
      let(:subscription_status) { 'active' }

      it { expect { subject }.to raise_error(SubscriptionIsNotPausedException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }
    end
  end
end
