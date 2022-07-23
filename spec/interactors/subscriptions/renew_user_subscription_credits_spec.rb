require 'rails_helper'

describe Subscriptions::RenewUserSubscriptionCredits do
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
    let!(:subscription) { create(:subscription, user: user, product: product) }

    let(:user_credits) { rand(1..10) }
    let(:user_subscription_credits) { rand(1..10) }
    let(:user_subscription_skill_session_credits) { rand(1..10) }

    let(:product_credits) { rand(1..10) }
    let(:product_skill_session_credits) { rand(1..10) }

    before do
      user.update!(
        credits: user_credits,
        subscription_credits: user_subscription_credits,
        subscription_skill_session_credits: user_subscription_skill_session_credits
      )
    end

    subject do
      Subscriptions::RenewUserSubscriptionCredits.call(user: user, subscription: subscription)
    end

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
