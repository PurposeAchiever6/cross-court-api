require 'rails_helper'

describe UserSessions::ConfirmFreeSessionIntent do
  describe '.call' do
    let!(:session) { create(:session) }
    let!(:user) { create(:user) }
    let!(:user_session) do
      create(
        :user_session,
        user: user,
        session: session,
        is_free_session: free_session,
        free_session_payment_intent: free_session_payment_intent
      )
    end

    let(:free_session) { true }
    let(:free_session_payment_intent) { rand(1_000).to_s }

    before { allow(StripeService).to receive(:confirm_intent) }

    subject { UserSessions::ConfirmFreeSessionIntent.call(user_session: user_session) }

    it 'calls Stripe service' do
      expect(StripeService).to receive(:confirm_intent).with(free_session_payment_intent)
      subject
    end

    context 'when is not a free session' do
      let(:free_session) { false }

      it 'do not call Stripe service' do
        expect(StripeService).not_to receive(:confirm_intent)
        subject
      end
    end

    context 'when does not have a free_session_payment_intent' do
      let(:free_session_payment_intent) { nil }

      it 'do not call Stripe service' do
        expect(StripeService).not_to receive(:confirm_intent)
        subject
      end
    end

    context 'when Stripe fails' do
      let(:stripe_error_msg) { 'Some error message' }

      before do
        allow_any_instance_of(Slack::Notifier).to receive(:ping)
        allow(
          StripeService
        ).to receive(:confirm_intent).and_raise(Stripe::StripeError, stripe_error_msg)
      end

      it 'calls Stripe service' do
        expect(StripeService).to receive(:confirm_intent).with(free_session_payment_intent)
        subject
      end

      it 'calls Slack service' do
        expect_any_instance_of(SlackService).to receive(:charge_error).with(
          'Free session no show fee',
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
