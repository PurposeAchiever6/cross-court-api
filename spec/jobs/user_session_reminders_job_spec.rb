require 'rails_helper'

describe UserSessionRemindersJob do
  describe '.perform' do
    before do
      ActiveCampaignMocker.new.mock
      allow(SonarService).to receive(:send_message).and_return(1)
      Timecop.freeze(Time.current)
    end

    after do
      Timecop.return
    end

    context 'when there are user_sessions booked' do
      let(:la_time)  { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
      let!(:user)    { create(:user) }
      let!(:la_date) { la_time.to_date }

      # In 24 hours
      let(:time_24)          { la_time.strftime(Session::TIME_FORMAT) }
      let(:s1)               { create(:session, :daily, time: time_24) }
      let!(:user_session1) do
        create(:user_session, date: la_date.tomorrow, session: s1, user: user)
      end

      # In 8 hours
      let(:time_8)         { (la_time + 8.hours).strftime(Session::TIME_FORMAT) }
      let(:s2)             { create(:session, :daily, time: time_8) }
      let!(:user_session2) { create(:user_session, date: la_date, session: s2, user: user) }

      # In 6 hours
      let(:first_session)  { false }
      let(:time_6)         { (la_time + 6.hours).strftime(Session::TIME_FORMAT) }
      let(:s3)             { create(:session, :daily, time: time_6) }
      let!(:user_session3) do
        create(
          :user_session,
          date: la_date,
          session: s3,
          user: user,
          first_session: first_session
        )
      end
      let(:message_6_hours) do
        I18n.t('notifier.sonar.today_reminder',
               name: user.first_name,
               time: time_6,
               location: user_session3.location.name,
               cancellation_period_hours: Session::CANCELLATION_PERIOD.to_i / 3600,
               frontend_url: ENV['FRONTENT_URL'],
               invite_friend: I18n.t('notifier.sonar.invite_friend',
                                     link: user_session3.invite_link))
      end

      it 'calls the SonarService with the correct parameters' do
        expect(SonarService).to receive(:send_message).with(user, message_6_hours).once

        described_class.perform_now
      end

      context 'when is the first session' do
        let(:first_session) { true }
        let(:expected_message) do
          I18n.t('notifier.sonar.today_reminder_first_timers',
                 name: user.first_name,
                 time: time_6,
                 location: user_session3.location.name,
                 cancellation_period_hours: Session::CANCELLATION_PERIOD.to_i / 3600,
                 frontend_url: ENV['FRONTENT_URL'],
                 invite_friend: I18n.t('notifier.sonar.invite_friend',
                                       link: user_session3.invite_link))
        end

        it 'calls the SonarService with the correct parameters' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          described_class.perform_now
        end
      end
    end
  end
end
