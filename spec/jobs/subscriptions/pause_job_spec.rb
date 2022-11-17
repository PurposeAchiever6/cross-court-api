require 'rails_helper'

describe ::Subscriptions::PauseJob do
  describe '#perform' do
    let!(:user) do
      create(
        :user,
        subscription_credits: rand(1..5),
        subscription_skill_session_credits: rand(1..2)
      )
    end
    let!(:subscription) { create(:subscription, user: user, status: subscription_status) }
    let!(:subscription_pause) { create(:subscription_pause, subscription: subscription) }

    let(:subscription_status) { 'active' }
    let(:resumes_at) { (Time.current + 1.month).to_i }

    before do
      Timecop.freeze(Time.current)
      StripeMocker.new.pause_subscription(subscription.stripe_id, resumes_at)
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
    end

    after { Timecop.return }

    subject { described_class.perform_now(subscription.id, resumes_at, subscription_pause.id) }

    it 'updates subscription status' do
      expect { subject }.to change {
        subscription.reload.status
      }.from('active').to('paused')
    end

    it 'updates subscription_pause status' do
      expect { subject }.to change {
        subscription_pause.reload.status
      }.from('upcoming').to('actual')
    end

    it 'updates user subscription credits' do
      expect { subject }.to change {
        user.reload.subscription_credits
      }.to(0)
    end

    it 'updates user subscription skill session credits' do
      expect { subject }.to change {
        user.reload.subscription_skill_session_credits
      }.to(0)
    end

    it 'sends a Slack message' do
      expect_any_instance_of(Slack::Notifier).to receive(:ping)
      subject
    end

    context 'when the subscription is not active' do
      let(:subscription_status) { 'paused' }

      it 'does not update the subscription status' do
        expect { subject }.not_to change { subscription.reload.status }
      end
    end
  end
end
