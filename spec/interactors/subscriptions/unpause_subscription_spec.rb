require 'rails_helper'

describe Subscriptions::UnpauseSubscription do
  describe '.call' do
    let(:subscription_status) { 'paused' }
    let!(:subscription) { create(:subscription, status: subscription_status) }
    let!(:subscription_pause) do
      create(:subscription_pause, subscription: subscription, status: :finished)
    end
    let(:user) { subscription.user }

    before do
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
      StripeMocker.new.unpause_subscription(subscription.stripe_id)
      user.update!(subscription_credits: 0)
    end

    subject { described_class.call(subscription: subscription) }

    it 'updates subscription status' do
      expect { subject }.to change {
        subscription.reload.status
      }.from(subscription_status).to('active')
    end

    it 'updates subscription_pause unpaused_at attr' do
      expect { subject }.to change {
        subscription_pause.reload.unpaused_at
      }.from(nil).to(anything)
    end

    it 'updates the user credits' do
      expect { subject }.to change {
        user.reload.subscription_credits
      }.from(0).to(subscription.product.credits)
    end

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(:subscription_unpaused)
      subject
    end

    context 'when the subscription is active' do
      let(:subscription_status) { 'active' }

      it { expect { subject }.to raise_error(SubscriptionIsNotPausedException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }

      it 'does not call Slack Service' do
        expect_any_instance_of(SlackService).not_to receive(:subscription_unpaused)
        subject rescue nil
      end
    end
  end
end
