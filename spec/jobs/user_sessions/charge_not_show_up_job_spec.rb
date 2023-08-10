require 'rails_helper'

describe UserSessions::ChargeNotShowUpJob do
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
    let(:user_cc_cash) { 0 }

    let!(:session) { create(:session) }
    let!(:user) { create(:user, cc_cash: user_cc_cash) }
    let!(:user_payment_method) { create(:payment_method, user:, default: true) }

    let!(:user_session_1) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: false,
        date: la_date.yesterday,
        state: :confirmed,
        is_free_session: true,
        first_session: true,
        free_session_payment_intent: rand(1_000)
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: false,
        date: la_date.yesterday,
        state: :confirmed,
        first_session: true,
        is_free_session: false
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: true,
        date: la_date.tomorrow,
        state: :confirmed,
        is_free_session: false
      )
    end
    let!(:user_session_4) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: false,
        date: la_date.yesterday,
        state: :confirmed,
        is_free_session: true,
        free_session_payment_intent: rand(1_000),
        no_show_up_fee_charged: true
      )
    end

    subject { described_class.perform_now }

    it { expect { subject }.to change { user_session_1.reload.state }.to('no_show') }
    it { expect { subject }.to change { user_session_2.reload.state }.to('no_show') }
    it { expect { subject }.not_to change { user_session_3.reload.state } }
    it { expect { subject }.not_to change { user_session_4.reload.state } }

    context 'when is free session' do
      it { expect { subject }.to change { user_session_1.reload.no_show_up_fee_charged }.to(true) }

      it 'calls Stripe service' do
        expect(StripeService).to receive(:confirm_intent).once
        subject
      end
    end

    context 'when is first session and user is not member' do
      let(:first_session) { true }

      it 'calls the Active Campaign service' do
        expect {
          subject
        }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default').twice
      end
    end

    context 'when we charge a no show up fee' do
      let(:no_show_up_fee) { '10' }

      before { ENV['NO_SHOW_UP_FEE'] = no_show_up_fee }

      it { expect { subject }.to change { user_session_2.reload.no_show_up_fee_charged }.to(true) }

      it 'calls Stripe service with correct params' do
        expect(StripeService).to receive(:charge).with(
          user,
          user_payment_method.stripe_id,
          ENV['NO_SHOW_UP_FEE'].to_f,
          'No show up fee'
        ).once

        subject
      end

      context 'when user has cc cash' do
        let(:user_cc_cash) { 50 }

        it 'does not call Stripe Service' do
          expect(StripeService).not_to receive(:charge)
          subject
        end

        context 'when user does not have enough cc cash to paid the totally of the fee' do
          let(:user_cc_cash) { 4.5 }

          it { expect { subject }.to change { user.reload.cc_cash }.to(0) }

          it 'calls Stripe service with correct params' do
            expect(StripeService).to receive(:charge).with(
              user,
              user_payment_method.stripe_id,
              5.5,
              'No show up fee'
            ).once

            subject
          end
        end
      end

      context 'when we do not charge a fee on no show up' do
        let(:no_show_up_fee) { '0' }

        it 'updates no_show_up_fee_charged attribute' do
          expect { subject }.to change { user_session_2.reload.no_show_up_fee_charged }.to(true)
        end

        it 'does not call Stripe Service' do
          expect(StripeService).not_to receive(:charge)
          subject
        end
      end
    end
  end
end
