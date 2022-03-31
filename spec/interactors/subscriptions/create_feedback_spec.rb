require 'rails_helper'

describe Subscriptions::CreateFeedback do
  describe '.call' do
    let!(:user) { create(:user) }
    let(:experience_rate) { rand(1..5) }
    let(:service_rate) { rand(1..5) }
    let(:recommend_rate) { rand(1..5) }
    let(:feedback) { 'Too expensive!!!' }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      Subscriptions::CreateFeedback.call(
        experiencie_rate: experience_rate,
        service_rate: service_rate,
        recommend_rate: recommend_rate,
        feedback: feedback,
        user: user
      )
    end

    it { expect(subject.subscription_feedback).to eq(SubscriptionFeedback.last) }

    it { expect { subject }.to change(SubscriptionFeedback, :count).by(1) }

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(:notify_subscription_feedback)
      subject
    end
  end
end
