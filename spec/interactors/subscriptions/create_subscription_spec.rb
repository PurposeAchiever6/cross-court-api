require 'rails_helper'

describe Subscriptions::CreateSubscription do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:payment_method) { create(:payment_method, user: user) }
    let!(:product) { create(:product) }
    let(:promo_code) { nil }
    let(:stripe_response_status) { 'active' }

    let(:stripe_response) do
      {
        id: 'stripe-subscription-id',
        items: double(data: [double(id: 'stripe-subscription-item-id')]),
        status: stripe_response_status,
        current_period_start: Time.current.to_i,
        current_period_end: (Time.current + 1.month).to_i,
        cancel_at: nil,
        canceled_at: nil,
        cancel_at_period_end: false
      }
    end

    before do
      allow(StripeService).to receive(:create_subscription).and_return(double(stripe_response))
    end

    subject do
      Subscriptions::CreateSubscription.call(
        user: user,
        product: product,
        payment_method_id: payment_method.id,
        promo_code: promo_code
      )
    end

    it { expect { subject }.to change(Subscription, :count).by(1) }

    it 'assigns the payment method to the subscription' do
      subject
      expect(Subscription.last.payment_method).to eq(payment_method)
    end

    it 'calls the stripes create_subscription method with the correct params' do
      expect(StripeService).to receive(
        :create_subscription
      ).with(user, product, payment_method.stripe_id, promo_code)
      subject
    end

    context 'when user already has an active subscription attribute is updated' do
      let!(:active_subscription) { create(:subscription, user: user, product: product) }

      it { expect(subject.success?).to eq(false) }
      it { expect { subject }.not_to change(Subscription, :count) }
    end

    context 'when stripe subscription returns with incomplete status' do
      let(:stripe_response_status) { 'incomplete' }

      it { expect(subject.success?).to eq(false) }
      it { expect { subject }.not_to change(Subscription, :count) }
    end
  end
end
