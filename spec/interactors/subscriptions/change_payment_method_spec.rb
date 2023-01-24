require 'rails_helper'

describe Subscriptions::ChangePaymentMethod do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:payment_method) { create(:payment_method, user:) }
    let!(:subscription) { create(:subscription, user:, status: subscription_status) }
    let!(:old_payment_method) { subscription.payment_method }

    let(:subscription_status) { 'active' }

    before { allow(Stripe::Subscription).to receive(:update) }

    subject do
      Subscriptions::ChangePaymentMethod.call(
        subscription:,
        payment_method:
      )
    end

    it { expect(subject.subscription).to eq(subscription) }

    it 'changes subscription payment method' do
      expect { subject }.to change {
        subscription.reload.payment_method
      }.from(old_payment_method).to(payment_method)
    end

    it 'calls Stripe Service with correct params' do
      expect(Stripe::Subscription).to receive(:update).with(
        subscription.stripe_id,
        { default_payment_method: payment_method.stripe_id }
      )
      subject
    end

    context 'when the subscription is not active' do
      let(:subscription_status) { 'canceled' }

      it { expect { subject }.to raise_error(SubscriptionIsNotActiveException) }

      it { expect { subject rescue nil }.not_to change { subscription.reload.payment_method } }
    end

    context 'when the subscription payment method is the same as the new one' do
      let!(:payment_method) { subscription.payment_method }

      it { expect(subject.subscription).to eq(subscription) }

      it { expect { subject }.not_to change { subscription.reload.payment_method } }

      it 'does not call Stripe' do
        expect(Stripe::Subscription).not_to receive(:update)
        subject
      end
    end
  end
end
