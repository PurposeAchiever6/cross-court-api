require 'rails_helper'

describe SessionRemindersJob do
  describe '.perform' do
    before do
      allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
      allow(SonarService).to receive(:send_message).and_return(1)
    end

    context 'when there are user_sessions booked' do
      let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
      let!(:user)   { create(:user) }

      # In 24 hours
      let(:time_24)          { la_time.strftime(Session::TIME_FORMAT) }
      let(:s1)               { create(:session, :daily, time: time_24) }
      let!(:user_session1)   { create(:user_session, date: Date.tomorrow, session: s1, user: user) }
      let(:message_24_hours) do
        I18n.t('notifier.tomorrow_reminder',
               name: user.first_name,
               time: time_24,
               location: user_session1.location.name)
      end

      # In 8 hours
      let(:time_8)         { (la_time + 8.hours).strftime(Session::TIME_FORMAT) }
      let(:s2)             { create(:session, :daily, time: time_8) }
      let!(:user_session2) { create(:user_session, date: Time.zone.today, session: s2, user: user) }
      let(:message_8_hours) do
        I18n.t('notifier.today_reminder',
               name: user.first_name,
               time: time_8,
               location: user_session2.location.name)
      end

      # In 6 hours
      let(:time_6)         { (la_time + 6.hours).strftime(Session::TIME_FORMAT) }
      let(:s3)             { create(:session, :daily, time: time_6) }
      let!(:user_session3) { create(:user_session, date: Time.zone.today, session: s3, user: user) }
      let(:message_6_hours) do
        I18n.t('notifier.today_reminder',
               name: user.first_name,
               time: time_6,
               location: user_session3.location.name)
      end

      # In 5 hours
      let(:time_5)         { (la_time + 5.hours).strftime(Session::TIME_FORMAT) }
      let(:s4)             { create(:session, :daily, time: time_5) }
      let!(:user_session4) { create(:user_session, date: Time.zone.today, session: s4, user: user) }
      let(:message_ultimatum) do
        I18n.t('notifier.ultimatum',
               name: user.first_name,
               time: time_5,
               location: user_session4.location.name)
      end

      it 'calls the SonarService with the correct parameters' do
        expect(SonarService).to receive(:send_message).with(user, message_24_hours).once
        expect(SonarService).to receive(:send_message).with(user, message_8_hours).once
        expect(SonarService).to receive(:send_message).with(user, message_6_hours).once
        expect(SonarService).to receive(:send_message).with(user, message_ultimatum).once

        described_class.perform_now
      end
    end
  end
end
