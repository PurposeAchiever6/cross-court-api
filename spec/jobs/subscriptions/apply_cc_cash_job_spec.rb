require 'rails_helper'

describe Subscriptions::ApplyCcCashJob do
  describe '#perform' do
    let(:price) { rand(50..80) }
    let(:product) { create(:product, price:) }
    let(:status) { :active }
    let(:subscription) { create(:subscription, product:, status:) }
    let(:cc_cash) { rand(100..200) }
    let(:apply_cc_cash_to_subscription) { true }
    let(:user) do
      create(
        :user,
        active_subscription: subscription,
        cc_cash:,
        apply_cc_cash_to_subscription:
      )
    end
    let(:discount) { nil }

    subject { Subscriptions::ApplyCcCashJob.perform_now(user.id, subscription.id) }

    it 'calls Subscriptions::ApplyCcCash' do
      expect(Subscriptions::ApplyCcCash).to receive(:call).once.with(user:, subscription:)
      subject
    end
  end
end
