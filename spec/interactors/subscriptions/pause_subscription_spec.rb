require 'rails_helper'

describe Subscriptions::PauseSubscription do
  describe '.call' do
    let(:subscription_status) { 'active' }
    let(:subscription) { create(:subscription, status: subscription_status) }
    let(:months) { %w[1 2].sample }
    let(:resumes_at) { (subscription.current_period_end - 1.day + months.to_i.months).to_i }

    before do
      Timecop.freeze(Time.current)
      StripeMocker.new.pause_subscription(subscription.stripe_id, resumes_at)
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
    end

    after { Timecop.return }

    subject { described_class.call(subscription: subscription, months: months) }

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

    it 'sends a Slack message' do
      expect_any_instance_of(Slack::Notifier).to receive(:ping)
      subject
    end

    context 'when the subscription is already paused' do
      let(:subscription_status) { 'paused' }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }
    end

    context 'when months are not valid' do
      let(:months) { '123' }

      it { expect { subject }.to raise_error(SubscriptionInvalidPauseMonthsException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }
    end

    context 'when no more pauses are available' do
      before do
        ENV['SUBSCRIPTION_PAUSES_PER_YEAR'] = '2'
        create_list(:subscription_pause, 2, subscription: subscription, status: :finished)
      end

      it { expect { subject }.to raise_error(MaximumNumberOfPausesReachedException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.status } }
    end
  end
end