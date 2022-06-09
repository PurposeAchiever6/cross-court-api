require 'rails_helper'

describe Users::Charge do
  describe '.call' do
    let!(:user) { create(:user, cc_cash: user_cc_cash) }
    let!(:default_payment_method) { create(:payment_method, user: user, default: true) }

    let(:price) { rand(10..100) }
    let(:description) { nil }
    let(:notify_error) { false }
    let(:use_cc_cash) { false }
    let(:user_cc_cash) { 0 }
    let(:payment_method) { nil }
    let(:payment_intent_id) { rand(1_000) }

    before do
      allow(StripeService).to receive(:charge).and_return(double(id: payment_intent_id))
    end

    subject do
      Users::Charge.call(
        user: user,
        price: price,
        description: description,
        payment_method: payment_method,
        notify_error: notify_error,
        use_cc_cash: use_cc_cash
      )
    end

    it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }

    it 'calls Stripe service with correct args' do
      expect(StripeService).to receive(:charge).with(
        user,
        default_payment_method.stripe_id,
        price,
        description
      )

      subject
    end

    context 'when user price is zero' do
      let(:price) { 0 }

      it { expect(subject.success?).to eq(true) }
    end

    context 'when price is not present' do
      let(:price) { nil }

      it { expect(subject.success?).to eq(false) }
      it { expect(subject.message).to eq('Price not present') }
    end

    context 'when user price is negative' do
      let(:price) { -1 }

      it { expect(subject.success?).to eq(false) }
      it { expect(subject.message).to eq('Price should be greater or equal than 0') }
    end

    context 'when user does not have any payment method' do
      let!(:default_payment_method) { nil }

      it { expect(subject.success?).to eq(false) }

      it 'returns the correct error message' do
        expect(subject.message).to eq('The user does not have a saved credit card to be charged')
      end

      it 'do not send a Slack message' do
        expect_any_instance_of(Slack::Notifier).not_to receive(:ping)
        subject
      end

      context 'when notify_error is true' do
        let(:notify_error) { true }

        it 'calls Slack service' do
          expect_any_instance_of(SlackService).to receive(:charge_error).with(
            description,
            'The user does not have a saved credit card to be charged'
          )
          subject
        end

        it 'sends a Slack message' do
          expect_any_instance_of(Slack::Notifier).to receive(:ping)
          subject
        end
      end
    end

    context 'when a payment method is passed as argument' do
      let!(:payment_method) { create(:payment_method, user: user) }

      it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }

      it 'calls Stripe service with correct args' do
        expect(StripeService).to receive(:charge).with(
          user,
          payment_method.stripe_id,
          price,
          description
        )

        subject
      end
    end

    context 'when stripe fails' do
      let(:stripe_error_msg) { 'Some error message' }

      before do
        allow(StripeService).to receive(:charge).and_raise(Stripe::StripeError, stripe_error_msg)
      end

      it { expect(subject.success?).to eq(false) }
      it { expect(subject.message).to eq(stripe_error_msg) }

      it 'do not send a Slack message' do
        expect_any_instance_of(Slack::Notifier).not_to receive(:ping)
        subject
      end

      context 'when notify_error is true' do
        let(:notify_error) { true }

        it 'calls Slack service' do
          expect_any_instance_of(SlackService).to receive(:charge_error).with(
            description,
            stripe_error_msg
          )
          subject
        end

        it 'sends a Slack message' do
          expect_any_instance_of(Slack::Notifier).to receive(:ping)
          subject
        end
      end
    end

    context 'when use_cc_cash is true' do
      let(:use_cc_cash) { true }

      context 'when user cc cash is greater than the price to charge' do
        let(:user_cc_cash) { price + 10 }

        it { expect(subject.charge_payment_intent_id).to eq(nil) }
        it { expect(subject.paid_with_cc_cash).to eq(true) }
        it { expect { subject }.to change { user.reload.cc_cash }.from(user_cc_cash).to(10) }

        it 'does not call Stripe service' do
          expect(StripeService).not_to receive(:charge)
          subject
        end
      end

      context 'when user cc cash is less than the price to charge' do
        let(:user_cc_cash) { price - 5 }

        it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }
        it { expect(subject.paid_with_cc_cash).to eq(nil) }
        it { expect { subject }.to change { user.reload.cc_cash }.from(user_cc_cash).to(0) }

        it 'calls Stripe service with correct args' do
          expect(StripeService).to receive(:charge).with(
            user,
            default_payment_method.stripe_id,
            price - user_cc_cash,
            description
          )

          subject
        end

        context 'when stripe fails' do
          before { allow(StripeService).to receive(:charge).and_raise(Stripe::StripeError) }

          it { expect { subject }.not_to change { user.reload.cc_cash } }
        end
      end

      context 'when user cc cash is zero' do
        let(:user_cc_cash) { 0 }

        it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }
        it { expect(subject.paid_with_cc_cash).to eq(nil) }
        it { expect { subject }.not_to change { user.reload.cc_cash } }

        it 'calls Stripe service with correct args' do
          expect(StripeService).to receive(:charge).with(
            user,
            default_payment_method.stripe_id,
            price,
            description
          )

          subject
        end
      end
    end
  end
end
