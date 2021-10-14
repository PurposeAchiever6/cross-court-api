require 'rails_helper'

describe InactiveUsersJob do
  describe '.perform' do
    let!(:session) { create(:session) }
    let!(:user) { create(:user, credits: user_credits) }

    let!(:user_session_1) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: Time.zone.today - 35.days
      )
    end
    let!(:user_session_2) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: true,
        date: Time.zone.today - date_ago_last_session,
        is_free_session: free_session
      )
    end
    let!(:user_session_3) do
      create(
        :user_session,
        user: user,
        session: session,
        checked_in: false,
        date: Time.zone.today + 2.days,
        state: :canceled
      )
    end

    let(:user_credits) { 0 }
    let(:date_ago_last_session) { [1.month, 14.days, 7.days].sample }
    let(:free_session) { false }

    subject { described_class.perform_now }

    context 'when user last checked in session was 1 month ago' do
      let(:date_ago_last_session) { 1.month }

      it 'calls service with the correct parameters' do
        expect_any_instance_of(SlackService).to receive(:notify).with(
          I18n.t('notifier.slack.inactive_user', name: user.full_name, phone: user.phone_number),
          channel: ENV['SLACK_CHANNEL_CHURN']
        ).once
        expect_any_instance_of(KlaviyoService).not_to receive(:event)

        subject
      end
    end

    context 'when user last checked in session was 14 days ago' do
      let(:date_ago_last_session) { 14.days }

      it 'calls service with the correct parameters' do
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end

      context 'when it was a free session' do
        let(:free_session) { true }

        it 'calls service with the correct parameters' do
          expect_any_instance_of(SlackService).to receive(:notify).with(
            I18n.t('notifier.slack.inactive_first_timer_user', name: user.full_name, phone: user.phone_number),
            channel: ENV['SLACK_CHANNEL_CHURN']
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
          user: user,
          session: session,
          checked_in: false,
          date: Time.zone.today + 4.days,
          state: :reserved
        )
      end

      it 'do not call service' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when the user last checked in session was before 1 month or 14 or 7 days ago' do
      let(:date_ago_last_session) { [27.days, 10.days, 5.days].sample }

      it 'do not call service' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when user has at least one credit' do
      let(:user_credits) { rand(1..10) }
      let(:date_ago_last_session) { [1.month, 14.days, 7.days].sample }

      it 'do not call service' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end

    context 'when user has an active subscription' do
      let(:subscription) { create(:subscription, status: :active) }

      before { user.subscriptions << subscription }

      it 'do not call service' do
        expect_any_instance_of(KlaviyoService).not_to receive(:event)
        expect_any_instance_of(SlackService).not_to receive(:notify)

        subject
      end
    end
  end
end
