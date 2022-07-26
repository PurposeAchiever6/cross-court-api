require 'rails_helper'

describe Subscriptions::RenewUserSubscriptionCredits do
  describe '.call' do
    let(:user_subscription_skill_session_credits) { rand(1..50) }
    let(:credits) { rand(1..50) }
    let(:subscription_credits) { rand(1..50) }
    let(:max_rollover_credits) { credits / 2 }
    let(:product_skill_session_credits) { rand(1..50) }
    let(:product) do
      create(
        :product,
        credits: credits,
        max_rollover_credits: max_rollover_credits,
        skill_session_credits: product_skill_session_credits
      )
    end
    let(:subscription) { create(:subscription, product: product) }
    let(:user) do
      create(
        :user,
        active_subscription: subscription,
        subscription_credits: subscription_credits,
        subscription_skill_session_credits: user_subscription_skill_session_credits
      )
    end

    subject { described_class.call(user: user, subscription: subscription) }

    it 'renews user subscription_skill_session_credits' do
      expect { subject }.to change {
        user.reload.subscription_skill_session_credits
      }.from(user_subscription_skill_session_credits).to(product_skill_session_credits)
    end

    context 'when is unlimited' do
      let(:credits) { Product::UNLIMITED }
      let(:subscription_credits) { Product::UNLIMITED }
      let(:max_rollover_credits) { nil }

      it 'expect not to change the user subscription credits' do
        expect { subject }.not_to change { user.reload.subscription_credits }
      end

      it 'stays as unlimited' do
        expect(user.reload.subscription_credits).to eq(Product::UNLIMITED)
      end
    end

    context 'when is not unlimited' do
      let(:credits) { [4, 8, 16, 32].sample }

      context 'when the user has less than max rollover credits' do
        let(:subscription_credits) { max_rollover_credits - 1 }

        it 'rollover the remaining credits' do
          expect { subject }.to change {
            user.reload.subscription_credits
          }.from(subscription_credits).to(credits + subscription_credits)
        end
      end

      context 'when the user has more than max rollover credits' do
        let(:subscription_credits) { max_rollover_credits + 1 }

        it 'rollover the remaining credits' do
          expect { subject }.to change {
            user.reload.subscription_credits
          }.from(subscription_credits).to(credits + max_rollover_credits)
        end
      end
    end
  end
end
