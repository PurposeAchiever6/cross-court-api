require 'rails_helper'

describe ChargeUser do
  describe '.call' do
    let(:user) { create(:user) }
    let(:price) { rand(100) }
    let(:description) { nil }
    let(:payment_intent_id) { rand(1_000) }

    before do
      allow(StripeService).to receive(:fetch_payment_methods).and_return([true])
      allow(StripeService).to receive(:charge).and_return(double(id: payment_intent_id))
    end

    subject { ChargeUser.call(user: user, price: price, description: description) }

    it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }

    context 'when user price is zero' do
      let(:price) { 0 }

      it { expect(subject.success?).to eq(false) }
      it { expect(subject.message).to eq('Price should be greater than 0') }
    end

    context 'when user does not have any payment method' do
      before { allow(StripeService).to receive(:fetch_payment_methods).and_return([]) }

      it { expect(subject.success?).to eq(false) }
      it do
        expect(subject.message).to eq('The user does not have a saved credit card to be charged')
      end
    end
  end
end
