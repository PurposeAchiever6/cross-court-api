require 'rails_helper'

describe Users::InactiveNonMembersJob do
  describe '.perform' do
    let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:la_date) { la_time.to_date }

    let!(:session) { create(:session) }
    let!(:user) { create(:user, credits: user_credits) }

    let!(:user_session_1) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: true,
        date: la_date - 35.days
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: true,
        date: la_date - date_ago_last_session,
        first_session:
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user:,
        session:,
        checked_in: false,
        date: la_date + 2.days,
        state: :canceled
      )
    end

    let(:user_credits) { 0 }
    let(:date_ago_last_session) { [1.month, 14.days, 7.days].sample }
    let(:first_session) { false }

    before do
      ActiveCampaignMocker.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).mock
    end

    subject { described_class.perform_now }

    context 'when user last checked in session was 1 month ago' do
      let(:date_ago_last_session) { 1.month }

      it 'calls service with the correct parameters' do
        expect_any_instance_of(SlackService).to receive(:notify).with(
          I18n.t('notifier.slack.inactive_user', name: user.full_name, phone: user.phone_number),
          channel: ENV.fetch('SLACK_CHANNEL_CHURN', nil)
        ).once
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)

        subject
      end
    end

    context 'when user last checked in session was 1 day ago' do
      let(:date_ago_last_session) { 1.day }

      it 'calls service with the correct parameters' do
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end

      context 'when it was his first session' do
        let(:first_session) { true }

        it 'calls service with the correct parameters' do
          expect_any_instance_of(SlackService).to receive(:notify).with(
            I18n.t('notifier.slack.inactive_first_timer_user',
                   name: user.full_name, phone: user.phone_number, last_session_days_ago: 1),
            channel: ENV.fetch('SLACK_CHANNEL_CHURN', nil)
          ).once

          subject
        end
      end
    end

    context 'when user last checked in session was 14 days ago' do
      let(:date_ago_last_session) { 14.days }

      it 'calls service with the correct parameters' do
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end

      context 'when it was his first session' do
        let(:first_session) { true }

        it 'calls service with the correct parameters' do
          expect_any_instance_of(SlackService).to receive(:notify).with(
            I18n.t('notifier.slack.inactive_first_timer_user',
                   name: user.full_name, phone: user.phone_number, last_session_days_ago: 14),
            channel: ENV.fetch('SLACK_CHANNEL_CHURN', nil)
          ).once

          subject
        end
      end
    end

    context 'when user last checked in session was 7 days ago' do
      let(:date_ago_last_session) { 7.days }

      it 'calls service with the correct parameters' do
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when user has a future session' do
      let!(:user_session_4) do
        create(
          :user_session,
          user:,
          session:,
          checked_in: false,
          date: la_date + 4.days,
          state: :reserved
        )
      end

      it 'do not call service' do
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when the user last checked in session was before 1 month or 14 or 7 days ago' do
      let(:date_ago_last_session) { [27.days, 10.days, 5.days].sample }

      it 'do not call service' do
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when user has at least one credit' do
      let(:user_credits) { rand(1..10) }
      let(:date_ago_last_session) { [1.month, 14.days, 7.days].sample }

      it 'do not call service' do
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when user has an active subscription' do
      let(:subscription) { create(:subscription, status: :active) }

      before { user.subscriptions << subscription }

      it 'do not call service' do
        expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end
  end
end
