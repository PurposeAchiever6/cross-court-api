require 'rails_helper'

describe Subscriptions::DeleteSubscription do
  describe '.call' do
    let!(:subscription) { create(:subscription, status: subscription_status) }

    let(:subscription_status) { 'active' }

    before { StripeMocker.new.cancel_subscription(subscription.stripe_id) }

    subject { Subscriptions::DeleteSubscription.call(subscription: subscription) }

    it 'updates subscription status' do
      expect { subject }.to change {
        subscription.reload.status
      }.from(subscription_status).to('canceled')
    end

    it 'calls Stripe Service with correct params' do
      expect(Stripe::Subscription).to receive(:delete).with(subscription.stripe_id)
      subject rescue nil
    end

    context 'when the subscription is already canceled' do
      let(:subscription_status) { 'canceled' }

      it { expect { subject }.to raise_error(SubscriptionAlreadyCanceledException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }
    end
  end
end
