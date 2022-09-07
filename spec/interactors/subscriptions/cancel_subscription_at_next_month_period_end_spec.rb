require 'rails_helper'

describe Subscriptions::CancelSubscriptionAtNextMonthPeriodEnd do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:subscription) do
      create(:subscription, user: user, status: status, cancel_at_period_end: cancel_at_period_end)
    end

    let(:status) { 'active' }
    let(:cancel_at_period_end) { false }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      Subscriptions::CancelSubscriptionAtNextMonthPeriodEnd.call(
        subscription: subscription
      )
    end

    it 'updates mark_cancel_at_period_end_at' do
      expect { subject }.to change {
        subscription.reload.mark_cancel_at_period_end_at
      }.from(nil).to(subscription.current_period_end.to_date + 2.days)
    end

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(
        :subscription_scheduled_cancellation
      ).with(subscription)

      subject
    end

    context 'when the subscription is already canceled' do
      let(:status) { 'canceled' }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it 'does not update mark_cancel_at_period_end_at attribute' do
        expect {
          subject rescue nil
        }.not_to change { subscription.reload.mark_cancel_at_period_end_at }
      end
    end

    context 'when the subscription will be canceled at period end' do
      let(:cancel_at_period_end) { true }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it 'does not update mark_cancel_at_period_end_at attribute' do
        expect {
          subject rescue nil
        }.not_to change { subscription.reload.mark_cancel_at_period_end_at }
      end
    end
  end
end
