require 'rails_helper'

describe Users::Charge do
  describe '.call' do
    let(:user) { create(:user) }
    let(:price) { rand(100) }
    let(:description) { nil }
    let(:notify_error) { false }
    let(:payment_intent_id) { rand(1_000) }
    let!(:payment_method) { create(:payment_method, user: user, default: true) }

    before do
      allow(StripeService).to receive(:charge).and_return(double(id: payment_intent_id))
    end

    subject do
      Users::Charge.call(
        user: user,
        price: price,
        description: description,
        notify_error: notify_error
      )
    end

    it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }

    context 'when user price is zero' do
      let(:price) { 0 }

      it { expect(subject.success?).to eq(false) }
      it { expect(subject.message).to eq('Price should be greater than 0') }
    end

    context 'when user does not have any payment method' do
      let!(:payment_method) { nil }

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
  end
end
