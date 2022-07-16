require 'rails_helper'

describe UserSessions::ReserveTeamJob do
  describe '.perform' do
    before do
      allow(SonarService).to receive(:send_message).and_return(1)
      Timecop.freeze(Time.current)
    end

    after do
      Timecop.return
    end

    context 'when there is place for the reserve team' do
      let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
      let!(:user) { create(:user, reserve_team: true) }
      let!(:la_date) { la_time.to_date }

      let(:session) { create(:session, :daily, time: time) }

      let(:message) do
        I18n.t(
          'notifier.sonar.reserve_team',
          time: time,
          location: session.location.name,
          link: "#{ENV['FRONTENT_URL']}/locations"
        )
      end

      context 'when the session is 5hs before' do
        let(:time) { (la_time + 5.hours).strftime(Session::TIME_FORMAT) }
        let!(:user_sessions) do
          create_list(
            :user_session,
            5,
            date: la_date,
            session: session,
            user: user
          )
        end

        it 'calls the SonarService with the correct parameters' do
          expect(SonarService).to receive(:send_message).with(user, message).once

          described_class.perform_now
        end
      end

      context 'when the session is 10hs before' do
        let(:time) { (la_time + 10.hours).strftime(Session::TIME_FORMAT) }
        let!(:user_session) do
          create(
            :user_session,
            date: la_date,
            session: session,
            user: user
          )
        end

        it 'calls the SonarService with the correct parameters' do
          expect(SonarService).to receive(:send_message).with(user, message).once

          described_class.perform_now
        end
      end

      context 'when the session is 1hs before' do
        let(:time) { (la_time + 1.hour).strftime(Session::TIME_FORMAT) }
        let!(:user_session) do
          create(
            :user_session,
            date: la_date,
            session: session,
            user: user
          )
        end

        it 'calls the SonarService with the correct parameters' do
          expect(SonarService).not_to receive(:send_message)

          described_class.perform_now
        end
      end
    end
  end
end
