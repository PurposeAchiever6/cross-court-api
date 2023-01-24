require 'rails_helper'

describe SubscriptionCancellationRequests::CancelAtNextMonthPeriodEnd do
  describe '.call' do
    let(:status) { :pending }
    let(:subscription) { subscription_cancellation_request.user.active_subscription }
    let!(:subscription_cancellation_request) do
      create(
        :subscription_cancellation_request,
        status:
      )
    end

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      SubscriptionCancellationRequests::CancelAtNextMonthPeriodEnd.call(
        subscription_cancellation_request:
      )
    end

    it 'updates subscription_cancellation_request status' do
      expect {
        subject
      }.to change {
        subscription_cancellation_request.reload.status
      }.to('cancel_at_next_month_period_end')
    end

    it { expect { subject }.to change { subscription.reload.mark_cancel_at_period_end_at } }

    context 'when subscription_cancellation_request is not pending' do
      let(:status) do
        %i[ignored
           cancel_at_current_period_end
           cancel_at_next_month_period_end
           cancel_immediately].sample
      end

      it 'does not update subscription_cancellation_request status' do
        expect {
          subject rescue nil
        }.not_to change { subscription_cancellation_request.reload.status }
      end

      it 'raises error SubscriptionCancellationRequestIsNotPendingException' do
        expect {
          subject
        }.to raise_error(
          SubscriptionCancellationRequestIsNotPendingException,
          'The cancellation request status should be pending'
        )
      end
    end
  end
end
