require 'rails_helper'

describe UserSessionAutoConfirmed do
  describe '.save!' do
    let!(:session) { create(:session, :daily, time: session_time) }
    let!(:user) { create(:user) }
    let!(:user_session) do
      create(
        :user_session,
        session: session,
        user: user,
        date: date,
        reminder_sent_at: reminder_sent_at,
        is_free_session: free_session
      )
    end

    let(:time_now) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:session_time) { time_now + Session::CANCELLATION_PERIOD - 1.minute }
    let(:date) { time_now.to_date }
    let(:reminder_sent_at) { nil }
    let(:free_session) { false }
    let(:expected_sms_message) do
      I18n.t('notifier.sonar.session_auto_confirmed',
             name: user.first_name,
             time: session.time.strftime(Session::TIME_FORMAT),
             location: user_session.location.name,
             frontend_url: ENV['FRONTENT_URL'],
             invite_friend: I18n.t('notifier.sonar.invite_friend',
                                   link: user_session.invite_link))
    end

    subject { UserSessionAutoConfirmed.new(user_session).save! }

    before do
      allow(SendSonar).to receive(:message_customer)
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
    end

    it { expect { subject }.to change { user_session.reload.state }.to('confirmed') }

    it 'updates reminder_sent_at column' do
      expect { subject }.to change { user_session.reload.reminder_sent_at }.from(nil).to(anything)
    end

    it 'calls Sonar service with expected args' do
      expect(SonarService).to receive(:send_message).with(user, expected_sms_message)
      subject
    end

    it 'enques ActiveCampaign::CreateDealJob' do
      expect { subject }.to have_enqueued_job(
        ::ActiveCampaign::CreateDealJob
      ).with(
        ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
        user.id,
        user_session_id: user_session.id
      )
    end

    context 'when the reminder has already been sent' do
      let(:reminder_sent_at) { time_now }

      it { expect { subject }.to change { user_session.reload.state }.to('confirmed') }

      it { expect { subject }.not_to change { user_session.reload.reminder_sent_at } }
    end

    context 'when is not in cancellation time' do
      let(:session_time) { time_now + Session::CANCELLATION_PERIOD + 1.minute }

      it { expect { subject }.not_to change { user_session.reload.state } }

      it { expect { subject }.not_to change { user_session.reload.reminder_sent_at } }

      it 'does not call Sonar service' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end

      it 'does not enque ActiveCampaign::CreateDealJob' do
        expect { subject }.not_to have_enqueued_job(
          ::ActiveCampaign::CreateDealJob
        )
      end
    end

    context 'when is a free session' do
      let(:free_session) { true }
      let(:expected_sms_message) do
        I18n.t('notifier.sonar.session_auto_confirmed_first_timers',
               name: user.first_name,
               time: session.time.strftime(Session::TIME_FORMAT),
               location: user_session.location.name,
               frontend_url: ENV['FRONTENT_URL'],
               invite_friend: I18n.t('notifier.sonar.invite_friend',
                                     link: user_session.invite_link))
      end

      it 'calls Sonar service with expected args' do
        expect(SonarService).to receive(:send_message).with(user, expected_sms_message)
        subject
      end
    end
  end
end