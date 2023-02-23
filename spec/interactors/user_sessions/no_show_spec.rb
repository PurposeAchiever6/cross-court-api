require 'rails_helper'

describe UserSessions::NoShow do
  describe '.call' do
    let!(:location) { create(:location) }
    let!(:session) { create(:session, :daily, location:, time: session_time) }
    let!(:payment_method) { create(:payment_method, user:, default: true) }
    let(:cc_cash) { 0 }
    let(:free_session_payment_intent) { nil }
    let!(:user) { create(:user, cc_cash:) }
    let!(:user_session) do
      create(
        :user_session,
        session:,
        user:,
        date:,
        is_free_session: free_session,
        free_session_payment_intent:
      )
    end
    let(:time_now) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let(:date) { time_now.to_date }
    let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }
    let(:free_session) { false }
    let(:user_payment_method) { user.default_payment_method }
    let(:no_show_up_fee) { '10' }

    before do
      ENV['NO_SHOW_UP_FEE'] = no_show_up_fee
      allow(SendSonar).to receive(:message_customer)
      allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000)))
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
    end

    subject { described_class.call(user_session:) }

    it { expect { subject }.to change { user_session.reload.state }.to('no_show') }

    it 'calls Sonar service' do
      expect(SonarService).to receive(:send_message).once

      subject
    end

    it 'calls Slack service' do
      expect_any_instance_of(SlackService).to receive(:no_show).once

      subject
    end

    it { expect { subject }.to change { user_session.reload.no_show_up_fee_charged }.to(true) }

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
      let(:cc_cash) { 50 }

      it 'does not call Stripe Service' do
        expect(StripeService).not_to receive(:charge)
        subject
      end

      context 'when user does not have enough cc cash to paid the totally of the fee' do
        let(:cc_cash) { 4.5 }

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
        expect { subject }.to change { user_session.reload.no_show_up_fee_charged }.to(true)
      end

      it 'does not call Stripe Service' do
        expect(StripeService).not_to receive(:charge)
        subject
      end
    end

    context 'when is free session' do
      let(:free_session) { true }
      let(:free_session_payment_intent) { rand(1_000) }

      before do
        ActiveCampaignMocker.new(
          pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
        ).mock
        allow(StripeService).to receive(:confirm_intent)
      end

      it 'calls ActiveCampaign service' do
        expect_any_instance_of(ActiveCampaignService).to receive(:create_deal).once
        subject
      end

      it 'calls Stripe service' do
        expect(StripeService).to receive(:confirm_intent).once
        subject
      end
    end
  end
end
