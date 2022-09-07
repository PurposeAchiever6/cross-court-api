require 'rails_helper'

describe Subscriptions::ChangeSubscription do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:new_payment_method) { create(:payment_method, user: user) }
    let!(:old_payment_method) { create(:payment_method, user: user) }
    let!(:new_product) { create(:product) }
    let!(:old_product) { create(:product) }
    let!(:active_subscription) do
      create(
        :subscription,
        user: user,
        payment_method: old_payment_method,
        product: old_product,
        mark_cancel_at_period_end_at: mark_cancel_at_period_end_at
      )
    end

    let(:proration_date) { nil }
    let(:promo_code) { nil }
    let(:stripe_response_status) { 'active' }
    let(:mark_cancel_at_period_end_at) { nil }

    let(:stripe_response) do
      {
        id: 'stripe-subscription-id',
        items: double(data: [double(id: 'new-stripe-subscription-item-id')]),
        status: stripe_response_status,
        current_period_start: Time.current.to_i,
        current_period_end: (Time.current + 1.month).to_i,
        cancel_at: nil,
        canceled_at: nil,
        cancel_at_period_end: false,
        pause_collection: nil
      }
    end

    before do
      allow(StripeService).to receive(:update_subscription).and_return(double(stripe_response))
    end

    subject do
      Subscriptions::ChangeSubscription.call(
        user: user,
        subscription: active_subscription,
        product: new_product,
        payment_method: new_payment_method,
        promo_code: promo_code,
        proration_date: proration_date
      )
    end

    it { expect(subject.success?).to eq(true) }
    it { expect(subject.subscription).to eq(active_subscription) }
    it { expect(subject.old_product).to eq(old_product) }
    it { expect(subject.old_promo_code).to eq(nil) }

    it 'changes active subscription product' do
      expect { subject }.to change {
        active_subscription.reload.product
      }.from(old_product).to(new_product)
    end

    it 'changes active subscription payment method' do
      expect { subject }.to change {
        active_subscription.reload.payment_method
      }.from(old_payment_method).to(new_payment_method)
    end

    it 'calls the stripes create_subscription method with the correct params' do
      expect(StripeService).to receive(
        :update_subscription
      ).with(
        active_subscription,
        new_product,
        new_payment_method.stripe_id,
        promo_code,
        proration_date
      )

      subject
    end

    context 'when the product is the same as the subscription' do
      let(:new_product) { old_product }

      it 'raises error SubscriptionHasSameProductException' do
        expect { subject }.to raise_error(
          SubscriptionHasSameProductException,
          'The subscription already has the selected product'
        )
      end
    end

    context 'when the payment method is the same as the subscription' do
      let(:new_payment_method) { old_payment_method }

      it { expect(subject.success?).to eq(true) }

      it { expect { subject }.not_to change { active_subscription.reload.payment_method } }
    end

    context 'when the subscription has set the attribute mark_cancel_at_period_end_at' do
      let(:mark_cancel_at_period_end_at) { Time.zone.today + 1.week }

      it { expect(subject.success?).to eq(true) }

      it 'updates mark_cancel_at_period_end_at to nil' do
        expect { subject }.to change {
          active_subscription.reload.mark_cancel_at_period_end_at
        }.from(mark_cancel_at_period_end_at).to(nil)
      end
    end
  end
end
