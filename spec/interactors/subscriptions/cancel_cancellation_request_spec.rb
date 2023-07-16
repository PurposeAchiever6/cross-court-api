require 'rails_helper'

describe Subscriptions::CancelCancellationRequest do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:subscription_cancellation_request) do
      create(
        :subscription_cancellation_request,
        user:,
        status:
      )
    end

    let(:subscription) { subscription_cancellation_request.user.active_subscription }
    let(:status) { :pending }

    subject { Subscriptions::CancelCancellationRequest.call(user:) }

    it { expect(subject.subscription).to eq(subscription) }

    it 'updates subscription_cancellation_request status' do
      expect {
        subject
      }.to change { subscription_cancellation_request.reload.status }.to('cancel_by_user')
    end

    context 'when subscription_cancellation_request is not pending' do
      let(:status) do
        %i[ignored
           cancel_at_current_period_end
           cancel_at_next_month_period_end
           cancel_immediately
           cancel_by_user].sample
      end

      it 'does not update subscription_cancellation_request status' do
        expect {
          subject rescue nil
        }.not_to change { subscription_cancellation_request.reload.status }
      end
    end

    context 'if user has more than 1 pending request cancellation' do
      let!(:subscription_cancellation_request_2) do
        create(
          :subscription_cancellation_request,
          user:,
          status:
        )
      end

      it 'updates subscription_cancellation_request status' do
        expect {
          subject
        }.to change { subscription_cancellation_request.reload.status }.to('cancel_by_user')
      end

      it 'updates subscription_cancellation_request_2 status' do
        expect {
          subject
        }.to change { subscription_cancellation_request_2.reload.status }.to('cancel_by_user')
      end
    end
  end
end
