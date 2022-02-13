require 'rails_helper'

describe ChargeNotShowUpPlayersJob do
  describe '#perform' do
    before do
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
      allow(StripeService).to receive(:confirm_intent)
      allow(StripeService).to receive(:charge).and_return(double(id: rand(1_000)))
      allow(StripeService).to receive(:fetch_payment_methods).and_return([true])
    end

    let(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:la_date) { la_time.to_date }
    let!(:session) { create(:session) }
    let(:subscription_credits) { 0 }
    let!(:user) { create(:user, credits: 0, subscription_credits: 0) }
    let!(:user_2) { create(:user, credits: 0, subscription_credits: Product::UNLIMITED) }

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
        user: user_2,
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
        user: user_2,
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

      it do
        expect_any_instance_of(ActiveCampaignService).to receive(:create_deal).once
        expect(StripeService).to receive(:confirm_intent).once

        subject
      end
    end

    context 'when user has unlimited credits' do
      it { expect { subject }.to change { user_session_2.reload.no_show_up_fee_charged }.to(true) }

      it do
        expect(StripeService).to receive(:fetch_payment_methods).once
        expect(StripeService).to receive(:charge).once

        subject
      end
    end
  end
end
