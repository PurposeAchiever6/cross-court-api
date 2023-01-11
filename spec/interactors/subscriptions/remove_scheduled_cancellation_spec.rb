require 'rails_helper'

describe Subscriptions::RemoveScheduledCancellation do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:subscription) do
      create(:subscription, user:, mark_cancel_at_period_end_at:)
    end

    let(:mark_cancel_at_period_end_at) { Time.zone.today + 1.week }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      Subscriptions::RemoveScheduledCancellation.call(
        subscription:
      )
    end

    it 'updates mark_cancel_at_period_end_at to nil' do
      expect { subject }.to change {
        subscription.reload.mark_cancel_at_period_end_at
      }.from(mark_cancel_at_period_end_at).to(nil)
    end

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(
        :subscription_scheduled_cancellation_removed
      ).with(subscription)

      subject
    end
  end
end
