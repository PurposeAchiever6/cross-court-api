require 'rails_helper'

describe UserSessions::Cancel do
  describe '.call' do
    let!(:location) { create(:location) }
    let!(:session) do
      create(:session, :daily, location:, time: session_time, is_open_club:, cost_credits:)
    end
    let!(:payment_method) { create(:payment_method, user:, default: true) }
    let(:cc_cash) { 0 }
    let(:free_session_payment_intent) { nil }
    let!(:user) do
      create(
        :user,
        subscription_credits:,
        subscription_skill_session_credits:,
        cc_cash:
      )
    end
    let!(:user_session) do
      create(
        :user_session,
        session:,
        user:,
        date:,
        is_free_session: free_session,
        credit_used_type:,
        scouting:,
        free_session_payment_intent:
      )
    end

    let(:cost_credits) { 1 }
    let(:is_open_club) { false }
    let(:subscription_credits) { 0 }
    let(:subscription_skill_session_credits) { 0 }
    let(:free_session) { false }
    let(:credit_used_type) { :credits }
    let(:time_now) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let(:session_time) { time_now + Session::CANCELLATION_PERIOD + 1.minute }
    let(:date) { time_now.to_date }
    let(:from_session_canceled) { false }
    let(:scouting) { false }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      UserSessions::Cancel.call(
        user_session:,
        from_session_canceled:
      )
    end

    it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
    it { expect { subject }.to change { user_session.reload.credit_reimbursed }.to(true) }
    it { expect { subject }.to change { user.reload.credits }.by(1) }
    it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
    it { expect { subject }.not_to change { user.reload.subscription_credits } }
    it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    it { expect { subject }.not_to change { user.reload.scouting_credits } }
    it { expect { subject }.not_to change { user.reload.free_session_state } }

    it 'calls Slack service' do
      expect_any_instance_of(SlackService).to receive(:session_canceled_in_time)
      subject
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(
        ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_IN_TIME,
        user.id,
        user_session_id: user_session.id
      )
    end

    context 'when the session costs 0 credits' do
      let(:cost_credits) { 0 }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user_session.reload.credit_reimbursed }.to(true) }
      it { expect { subject }.not_to change { user.reload.credits } }
    end

    context 'when the session costs 2 credits' do
      let(:cost_credits) { 2 }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user_session.reload.credit_reimbursed }.to(true) }
      it { expect { subject }.to change { user.reload.credits }.by(2) }
    end

    context 'when is free session' do
      let(:free_session) { true }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }
    end

    context 'when is open club' do
      let(:is_open_club) { true }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user.reload.free_session_state } }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when user has unlimited subscription credits' do
      let(:subscription_credits) { Product::UNLIMITED }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.credits }.by(1) }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when user has unlimited subscription skill session credits' do
      let(:subscription_credits) { Product::UNLIMITED }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.credits }.by(1) }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when the session reservation was made with not_charge_user_credit' do
      let(:credit_used_type) { :not_charge_user_credit }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when session reservation was made by a free booking' do
      let(:credit_used_type) { :allow_free_booking }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when the session reservation was made with cost credits in zero' do
      let(:credit_used_type) { :no_credit_required }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when user session credit used was from season pass credits' do
      let(:credit_used_type) { :credits_without_expiration }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.credits_without_expiration }.by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
    end

    context 'when user session credit used was from subscription credits' do
      let(:credit_used_type) { :subscription_credits }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.subscription_credits }.by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }

      context 'when user has unlimited subscription credits' do
        let(:subscription_credits) { Product::UNLIMITED }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
        it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
      end
    end

    context 'when user session credit used was from skill session credits' do
      let(:credit_used_type) { :subscription_skill_session_credits }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.subscription_skill_session_credits }.by(1) }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
      it { expect { subject }.not_to change { user.reload.subscription_credits } }

      context 'when user has unlimited subscription skill session credits' do
        let(:subscription_skill_session_credits) { Product::UNLIMITED }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.not_to change { user.reload.subscription_skill_session_credits } }
        it { expect { subject }.not_to change { user.reload.credits } }
        it { expect { subject }.not_to change { user.reload.credits_without_expiration } }
        it { expect { subject }.not_to change { user.reload.subscription_credits } }
      end
    end

    context 'when cancellation is not in time' do
      let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }
      let(:free_session_cancel_fee) { rand(1_000).to_s }
      let(:late_cancel_fee) { rand(1_000).to_s }

      before do
        ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE'] = free_session_cancel_fee
        ENV['CANCELED_OUT_OF_TIME_PRICE'] = late_cancel_fee
        allow(StripeService).to receive(:fetch_payment_methods).and_return([true])
        allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000)))
      end

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user_session.reload.credit_reimbursed } }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.free_session_state } }

      it 'calls Stripe service' do
        expect(StripeService).to receive(:charge).with(
          user,
          payment_method.stripe_id,
          late_cancel_fee.to_f,
          'Session canceled out of time fee'
        )
        subject
      end

      it 'calls Slack service' do
        expect_any_instance_of(SlackService).to receive(:session_canceled_out_of_time)
        subject
      end

      it 'enques ActiveCampaign::CreateDealJob' do
        expect { subject }.to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        ).with(
          ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_OUT_OF_TIME,
          user.id,
          user_session_id: user_session.id,
          amount_charged: late_cancel_fee.to_f,
          unlimited_credits: 'false'
        )
      end

      context 'when is free session' do
        let(:free_session) { true }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.to change { user.reload.credits }.by(1) }
        it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }

        it 'calls Stripe service' do
          expect(StripeService).to receive(:charge).with(
            user,
            payment_method.stripe_id,
            free_session_cancel_fee.to_f,
            'Session canceled out of time fee'
          )
          subject
        end

        it 'enques ActiveCampaign::CreateDealJob' do
          expect { subject }.to have_enqueued_job(
            ::ActiveCampaign::CreateDealJob
          ).with(
            ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_OUT_OF_TIME,
            user.id,
            user_session_id: user_session.id,
            amount_charged: free_session_cancel_fee.to_f,
            unlimited_credits: 'false'
          )
        end
      end

      context 'when user has unlimited credits' do
        let(:subscription_credits) { Product::UNLIMITED }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.not_to change { user.reload.credits } }

        it 'enques ActiveCampaign::CreateDealJob' do
          expect { subject }.to have_enqueued_job(
            ::ActiveCampaign::CreateDealJob
          ).with(
            ::ActiveCampaign::Deal::Event::SESSION_CANCELLED_OUT_OF_TIME,
            user.id,
            user_session_id: user_session.id,
            amount_charged: late_cancel_fee.to_f,
            unlimited_credits: 'true'
          )
        end
      end
    end

    context 'when from_session_canceled is true' do
      let(:from_session_canceled) { true }
      let(:session_time) do
        [
          time_now + Session::CANCELLATION_PERIOD + 1.minute,
          time_now + Session::CANCELLATION_PERIOD - 1.minute
        ].sample
      end

      before { allow(SendSonar).to receive(:message_customer) }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user_session.reload.credit_reimbursed }.to(true) }
      it { expect { subject }.to change { user.reload.credits }.by(1) }
      it { expect { subject }.not_to change { user.reload.free_session_state } }

      it 'calls Slack service' do
        expect_any_instance_of(SlackService).to receive(:session_canceled)
        subject
      end

      it 'calls Sonar service' do
        expect(SonarService).to receive(:send_message).with(
          user,
          /has been canceled. Don't worry, we refunded your credit/
        )
        subject
      end

      context 'when is free session' do
        let(:free_session) { true }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }
      end
    end

    context 'when it has session guests' do
      let!(:session_guest_1) { create(:session_guest, user_session:) }
      let!(:session_guest_2) { create(:session_guest, user_session:) }

      it { expect { subject }.to change { session_guest_1.reload.state }.to('canceled') }
      it { expect { subject }.to change { session_guest_2.reload.state }.to('canceled') }

      it { expect { subject }.to have_enqueued_job(::Sonar::SendMessageJob).twice }
    end

    context 'when the user session has a shooting machine reserved' do
      let(:status) { :reserved }
      let!(:shooting_machine_reservation) do
        create(:shooting_machine_reservation, user_session:, status:)
      end

      it 'updates the shooting machine reservation status' do
        expect { subject }.to change { shooting_machine_reservation.reload.status }.to('canceled')
      end

      context 'when the shooting machine reservation has been canceled' do
        let(:status) { :canceled }

        it { expect { subject }.not_to change { shooting_machine_reservation.reload.status } }

        it 'does not call ShootingMachineReservations::Cancel' do
          expect(ShootingMachineReservations::Cancel).not_to receive(:call)
          subject
        end
      end
    end

    context 'when the user session has been marked for scouting' do
      let(:scouting) { true }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user_session.reload.credit_reimbursed }.to(true) }
      it { expect { subject }.to change { user.reload.credits }.by(1) }
      it { expect { subject }.to change { user.reload.scouting_credits }.by(1) }
    end
  end
end
