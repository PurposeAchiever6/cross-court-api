require 'rails_helper'

describe CreateSubscription do
  describe '.call' do
    let(:user) { create(:user) }
    let(:product) { create(:product) }
    let(:payment_method) { 'some-stripe-pm-id' }
    let(:promo_code) { nil }

    let(:stripe_response) do
      {
        id: 'stripe-subscription-id',
        items: double(data: [double(id: 'stripe-subscription-item-id')]),
        status: 'active',
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
      CreateSubscription.call(user: user, product: product, payment_method: payment_method, promo_code: promo_code)
    end

    it { expect { subject }.to change(Subscription, :count).by(1) }

    it 'calls the stripes create_subscription method with the correct params' do
      expect(StripeService).to receive(:create_subscription).with(user, product, payment_method, promo_code)
      subject
    end

    context 'when user already has an active subscription attribute is updated' do
      let!(:active_subscription) { create(:subscription, user: user, product: product) }

      it { expect(subject.success?).to eq(false) }
    end
  end
end
