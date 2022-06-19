require 'rails_helper'

describe UserSessions::Cancel do
  describe '.call' do
    let!(:location) { create(:location) }
    let!(:session) { create(:session, :daily, location: location, time: session_time) }
    let!(:user) { create(:user, subscription_credits: subscription_credits) }
    let!(:payment_method) { create(:payment_method, user: user, default: true) }
    let!(:user_session) do
      create(:user_session, session: session, user: user, date: date, is_free_session: free_session)
    end

    let(:subscription_credits) { 0 }
    let(:free_session) { false }
    let(:time_now) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let(:session_time) { time_now + Session::CANCELLATION_PERIOD + 1.minute }
    let(:date) { time_now.to_date }
    let(:from_session_canceled) { false }

    before { allow_any_instance_of(Slack::Notifier).to receive(:ping) }

    subject do
      UserSessions::Cancel.call(
        user_session: user_session,
        from_session_canceled: from_session_canceled
      )
    end

    it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
    it { expect { subject }.to change { user_session.reload.credit_reimbursed }.to(true) }
    it { expect { subject }.to change { user.reload.credits }.by(1) }
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

    context 'when is free session' do
      let(:free_session) { true }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }
    end

    context 'when user has unlimited credits' do
      let(:subscription_credits) { Product::UNLIMITED }

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user.reload.credits } }
    end

    context 'when cancellation is not in time' do
      let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }
      let(:free_session_cancel_fee) { rand(1_000).to_s }
      let(:unlimited_membership_cancel_fee) { rand(1_000).to_s }

      before do
        ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE'] = free_session_cancel_fee
        ENV['UNLIMITED_CREDITS_CANCELED_OUT_OF_TIME_PRICE'] = unlimited_membership_cancel_fee
        allow(StripeService).to receive(:fetch_payment_methods).and_return([true])
        allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000)))
      end

      it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
      it { expect { subject }.not_to change { user_session.reload.credit_reimbursed } }
      it { expect { subject }.not_to change { user.reload.credits } }
      it { expect { subject }.not_to change { user.reload.free_session_state } }

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
          amount_charged: 0,
          unlimited_credits: 'false'
        )
      end

      context 'when is free session' do
        let(:free_session) { true }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.to change { user.reload.credits }.by(1) }
        it { expect { subject }.to change { user.reload.free_session_state }.to('claimed') }

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
            amount_charged: unlimited_membership_cancel_fee.to_f,
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

      context 'when user has unlimited credits' do
        let(:subscription_credits) { Product::UNLIMITED }

        it { expect { subject }.to change { user_session.reload.state }.to('canceled') }
        it { expect { subject }.not_to change { user.reload.credits } }
      end
    end
  end
end
