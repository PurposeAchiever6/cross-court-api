require 'rails_helper'

describe Subscriptions::CreateCancellationRequest do
  describe '.call' do
    let!(:user) { create(:user) }
    let(:experience_rate) { rand(1..5) }
    let(:service_rate) { rand(1..5) }
    let(:recommend_rate) { rand(1..5) }
    let(:reason) { 'Too expensive!!!' }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      Subscriptions::CreateCancellationRequest.call(
        experiencie_rate: experience_rate,
        service_rate: service_rate,
        recommend_rate: recommend_rate,
        reason: reason,
        user: user
      )
    end

    it 'creates a subscription_cancellation_request' do
      expect(subject.subscription_cancellation_request).to eq(SubscriptionCancellationRequest.last)
    end

    it { expect { subject }.to change(SubscriptionCancellationRequest, :count).by(1) }

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(:notify_subscription_cancellation_request)
      subject
    end

    it 'sends session booked email' do
      expect { subject }.to have_enqueued_job(
        ActionMailer::MailDeliveryJob
      ).with('SubscriptionMailer', 'cancellation_request', anything, anything)
    end
  end
end
