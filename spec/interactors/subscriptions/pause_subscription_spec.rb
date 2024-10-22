require 'rails_helper'

describe Subscriptions::PauseSubscription do
  describe '.call' do
    let(:subscription_status) { 'active' }
    let(:product) { create(:product, free_pauses_per_year: 2) }
    let(:subscription) { create(:subscription, product:, status: subscription_status) }
    let(:months) { 1 }
    let(:resumes_at) { (subscription.current_period_end - 1.day + months.to_i.months).to_i }

    before do
      Timecop.freeze(Time.current)
      StripeMocker.new.pause_subscription(subscription.stripe_id, resumes_at)
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
    end

    after { Timecop.return }

    subject { described_class.call(subscription:) }

    it 'enques ::Subscriptions::PauseJob' do
      expect { subject }.to have_enqueued_job(
        ::Subscriptions::PauseJob
      ).with(
        subscription.id,
        resumes_at,
        anything
      )
    end

    it 'creates a subscription pause' do
      expect { subject }.to change { SubscriptionPause.count }.by(1)
    end

    it 'creates a non paid subscription pause' do
      subject

      subscription_pause = SubscriptionPause.last
      expect(subscription_pause.paid).to eq(false)
    end

    it 'sends a Slack message' do
      expect_any_instance_of(Slack::Notifier).to receive(:ping)
      subject
    end

    context 'when the pause is paid' do
      before do
        create_list(:subscription_pause, 2, subscription:, status: :finished)
      end

      it 'creates a paid subscription pause' do
        subject

        subscription_pause = SubscriptionPause.last
        expect(subscription_pause.paid).to eq(true)
      end
    end

    context 'when the subscription is already paused' do
      let(:subscription_status) { 'paused' }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }
    end
  end
end
