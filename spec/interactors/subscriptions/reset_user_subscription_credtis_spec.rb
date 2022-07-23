require 'rails_helper'

describe Subscriptions::ResetUserSubscriptionCredits do
  describe '.call' do
    let!(:user) do
      create(
        :user,
        credits: user_credits,
        subscription_credits: user_subscription_credits,
        subscription_skill_session_credits: user_subscription_skill_session_credits
      )
    end

    let(:user_credits) { rand(1..10) }
    let(:user_subscription_credits) { rand(1..10) }
    let(:user_subscription_skill_session_credits) { rand(1..10) }

    subject do
      Subscriptions::ResetUserSubscriptionCredits.call(user: user)
    end

    it 'does not update user credits' do
      expect { subject }.not_to change { user.reload.credits }
    end

    it 'updates user subscription_credits' do
      expect { subject }.to change {
        user.reload.subscription_credits
      }.from(user_subscription_credits).to(0)
    end

    it 'updates user subscription_skill_session_credits' do
      expect { subject }.to change {
        user.reload.subscription_skill_session_credits
      }.from(user_subscription_skill_session_credits).to(0)
    end
  end
end
