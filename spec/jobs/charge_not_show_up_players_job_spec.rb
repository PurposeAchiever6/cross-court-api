require 'rails_helper'

describe ChargeNotShowUpPlayersJob do
  describe '#perform' do
    before do
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
      allow(StripeService).to receive(:confirm_intent)
      allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000)))
    end

    let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:la_date) { la_time.to_date }
    let(:unlimited_user_cc_cash) { 0 }

    let!(:session) { create(:session) }

    let!(:user) { create(:user) }
    let!(:unlimited_user) do
      create(:user, subscription_credits: Product::UNLIMITED, cc_cash: unlimited_user_cc_cash)
    end

    let!(:user_payment_method) { create(:payment_method, user: user, default: true) }
    let!(:unlimited_user_payment_method) do
      create(:payment_method, user: unlimited_user, default: true)
    end

    let!(:user_session_1) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: false,
        date: la_date.yesterday,
        state: :confirmed,
        is_free_session: true,
        free_session_payment_intent: rand(1_000)
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: unlimited_user,
        session: session,
        checked_in: false,
        date: la_date.yesterday,
        state: :confirmed,
        is_free_session: false
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: unlimited_user,
        session: session,
        checked_in: true,
        date: la_date.tomorrow,
        state: :confirmed,
        is_free_session: false
      )
    end
    let!(:user_session_4) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: false,
        date: la_date.yesterday,
        state: :confirmed,
        is_free_session: true,
        free_session_payment_intent: rand(1_000),
        no_show_up_fee_charged: true
      )
    end

    subject { described_class.perform_now }

    context 'when is free session' do
      it { expect { subject }.to change { user_session_1.reload.no_show_up_fee_charged }.to(true) }

      it 'calls ActiveCampaign service' do
        expect(StripeService).to receive(:confirm_intent).once
        subject
      end

      it 'calls Stripe service' do
        expect(StripeService).to receive(:confirm_intent).once
        subject
      end
    end

    context 'when user has unlimited credits' do
      it { expect { subject }.to change { user_session_2.reload.no_show_up_fee_charged }.to(true) }

      it 'calls Stripe service with correct params' do
        expect(StripeService).to receive(:charge).with(
          unlimited_user,
          unlimited_user_payment_method.stripe_id,
          ENV['UNLIMITED_CREDITS_NO_SHOW_UP_FEE'].to_f,
          'Unlimited membership no show fee'
        )

        subject
      end

      context 'when user has cc cash' do
        let(:unlimited_user_cc_cash) { 50 }

        before { ENV['UNLIMITED_CREDITS_NO_SHOW_UP_FEE'] = '10' }

        it 'does not call Stripe Service' do
          expect(StripeService).not_to receive(:charge)
          subject
        end

        context 'when user does not have enough cc cash to paid the totally of the fee' do
          let(:unlimited_user_cc_cash) { 4.5 }

          it { expect { subject }.to change { unlimited_user.reload.cc_cash }.to(0) }

          it 'calls Stripe service with correct params' do
            expect(StripeService).to receive(:charge).with(
              unlimited_user,
              unlimited_user_payment_method.stripe_id,
              5.5,
              'Unlimited membership no show fee'
            )

            subject
          end
        end
      end
    end
  end
end
