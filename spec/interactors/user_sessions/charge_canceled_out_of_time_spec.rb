require 'rails_helper'

describe UserSessions::ChargeCanceledOutOfTime do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:session) { create(:session, :daily, time: session_time) }
    let!(:user_session) do
      create(:user_session, user: user, session: session, is_free_session: is_free_session)
    end

    let(:los_angeles_time) do
      Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
    end
    let(:free_session_price_to_charge) { rand(1_000).to_s }
    let(:unlimited_credits_price_to_charge) { rand(1_000).to_s }
    let(:payment_intent_id) { rand(1_000) }
    let(:is_free_session) { false }
    let(:session_time) { los_angeles_time + Session::CANCELLATION_PERIOD - 1.minute }

    before do
      ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE'] = free_session_price_to_charge
      ENV['UNLIMITED_CREDITS_CANCELED_OUT_OF_TIME_PRICE'] = unlimited_credits_price_to_charge
      allow(StripeService).to receive(:fetch_payment_methods).and_return([true])
      allow(StripeService).to receive(:charge).and_return(double(id: payment_intent_id))
    end

    subject { UserSessions::ChargeCanceledOutOfTime.call(user_session: user_session) }

    it { expect(subject.amount_charged).to eq(0) }
    it { expect(subject.charge_payment_intent_id).to eq(nil) }

    context 'when user session is free' do
      let(:is_free_session) { true }

      it { expect(subject.amount_charged).to eq(free_session_price_to_charge.to_f) }
      it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }

      it 'calls Users::Charge with right price' do
        expect(Users::Charge).to receive(:call).with(
          user: user,
          price: free_session_price_to_charge.to_f,
          description: 'Session canceled out of time fee',
          notify_error: true
        ).once

        subject rescue nil
      end
    end

    context 'when user has unlimited credits' do
      before { user.update!(subscription_credits: Product::UNLIMITED) }

      it { expect(subject.amount_charged).to eq(unlimited_credits_price_to_charge.to_f) }
      it { expect(subject.charge_payment_intent_id).to eq(payment_intent_id) }

      it 'calls Users::Charge with right price' do
        expect(Users::Charge).to receive(:call).with(
          user: user,
          price: unlimited_credits_price_to_charge.to_f,
          description: 'Session canceled out of time fee',
          notify_error: true
        ).once

        subject rescue nil
      end
    end

    context 'when user session is not out of time for cancellation' do
      let(:session_time) { los_angeles_time + Session::CANCELLATION_PERIOD + 1.minute }

      it { expect(subject.charge_payment_intent_id).to eq(nil) }
    end
  end
end
