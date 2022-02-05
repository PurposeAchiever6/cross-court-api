require 'rails_helper'

describe RefereeSessionRemindersJob do
  describe '.perform' do
    let(:referee_sessions_notifications_enabled) { 'true' }

    before do
      ActiveCampaignMocker.new.mock
      allow(SonarService).to receive(:send_message).and_return(1)
      Timecop.freeze(Time.current)
      ENV['REFEREE_SESSIONS_NOTIFICATIONS_ENABLED'] = referee_sessions_notifications_enabled
    end

    after do
      Timecop.return
    end

    context 'when there are referee_sessions booked' do
      let(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
      let!(:user)    { create(:user) }
      let!(:la_date) { la_time.to_date }

      # In 24 hours
      let(:time_24)           { la_time.strftime(Session::TIME_FORMAT) }
      let(:s1)                { create(:session, :daily, time: time_24) }
      let!(:referee_session1) do
        create(:referee_session, date: la_date.tomorrow, session: s1, user: user)
      end
      let(:message_24_hours) do
        I18n.t('notifier.sonar.referee_tomorrow_reminder',
               name: user.first_name,
               time: time_24,
               location: referee_session1.location.name)
      end

      # In 12 hours
      let(:time_12)           { (la_time + 12.hours).strftime(Session::TIME_FORMAT) }
      let(:s2)                { create(:session, :daily, time: time_12) }
      let!(:referee_session2) { create(:referee_session, date: la_date, session: s2, user: user) }
      let(:message_12_hours) do
        I18n.t('notifier.sonar.referee_today_reminder',
               name: user.first_name,
               time: time_12,
               location: referee_session2.location.name)
      end

      it 'calls the SonarService with the correct parameters' do
        expect(SonarService).to receive(:send_message).with(user, message_24_hours).once
        expect(SonarService).to receive(:send_message).with(user, message_12_hours).once

        described_class.perform_now
      end

      context 'when notifications are disabled' do
        let(:referee_sessions_notifications_enabled) { 'false' }

        it 'does not call the SonarService' do
          expect(SonarService).not_to receive(:send_message)
          expect(SonarService).not_to receive(:send_message)

          described_class.perform_now
        end
      end
    end
  end
end
