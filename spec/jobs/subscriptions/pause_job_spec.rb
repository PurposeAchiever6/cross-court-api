require 'rails_helper'

describe ::Subscriptions::PauseJob do
  describe '#perform' do
    let(:subscription_status) { 'active' }
    let(:subscription) { create(:subscription, status: subscription_status) }
    let(:subscription_pause) { create(:subscription_pause, subscription: subscription) }
    let(:resumes_at) { (Time.current + 1.month).to_i }

    before do
      Timecop.freeze(Time.current)
      StripeMocker.new.pause_subscription(subscription.stripe_id, resumes_at)
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

    context 'when the subscription is not active' do
      let(:subscription_status) { 'paused' }

      it 'does not update the subscription status' do
        expect { subject }.not_to change { subscription.reload.status }
      end
    end
  end
end
