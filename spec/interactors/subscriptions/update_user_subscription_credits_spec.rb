require 'rails_helper'

describe Subscriptions::UpdateUserSubscriptionCredits do
  describe '.call' do
    let!(:user) do
      create(
        :user,
        credits: user_credits,
        subscription_credits: user_subscription_credits,
        subscription_skill_session_credits: user_subscription_skill_session_credits
      )
    end
    let!(:product) do
      create(
        :product,
        credits: product_credits,
        skill_session_credits: product_skill_session_credits
      )
    end

    let(:user_credits) { rand(1..1000) }
    let(:user_subscription_credits) { rand(1..1000) }
    let(:user_subscription_skill_session_credits) { rand(1..1000) }

    let(:product_credits) { rand(1..1000) }
    let(:product_skill_session_credits) { rand(1..1000) }

    subject { Subscriptions::UpdateUserSubscriptionCredits.call(user: user, product: product) }

    it 'does not update user credits' do
      expect { subject }.not_to change { user.reload.credits }
    end

    it 'updates user subscription_credits' do
      expect { subject }.to change {
        user.reload.subscription_credits
      }.from(user_subscription_credits).to(product_credits)
    end

    it 'updates user subscription_skill_session_credits' do
      expect { subject }.to change {
        user.reload.subscription_skill_session_credits
      }.from(user_subscription_skill_session_credits).to(product_skill_session_credits)
    end
  end
end
