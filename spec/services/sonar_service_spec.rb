require 'rails_helper'

describe SonarService do
  describe '.message_received' do
    before do
      ActiveCampaignMocker.new.mock
      allow_any_instance_of(SlackService).to receive(:session_confirmed).and_return(1)
      allow_any_instance_of(SlackService).to receive(:session_canceled_in_time).and_return(1)
      allow_any_instance_of(SlackService).to receive(:session_canceled_out_of_time).and_return(1)
      allow(SonarService).to receive(:send_message).and_return(1)
      Timecop.freeze(Time.current)
    end

    after do
      Timecop.return
    end

    let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:la_date) { la_time.to_date }
    let(:time_24) { la_time.strftime(Session::TIME_FORMAT) }
    let(:employee) { false }
    let(:state) { :reserved }

    let!(:user) { create(:user, is_referee: employee) }
    let!(:session) { create(:session, :daily, time: time_24) }
    let!(:user_session) do
      create(:user_session, date: la_date.tomorrow, session:, user:, state:)
    end

    subject { SonarService.message_received(user, text) }

    context 'when the message is positive' do
      let(:text) { %w[yes y].sample }
      let(:expected_message) { I18n.t('notifier.sonar.no_more_sonar_confirmation') }

      it 'sends the confirmation message' do
        expect(SonarService).to receive(:send_message).with(user, expected_message).once

        subject
      end

      context 'when the user does not have any session' do
        before { user_session.destroy! }

        let(:expected_message) { I18n.t('notifier.sonar.no_session_booked') }

        it 'sends the no session booked message' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          subject
        end
      end

      context 'when the user session is already confirmed' do
        let(:state) { :confirmed }

        let(:expected_message) { I18n.t('notifier.sonar.no_more_sonar_confirmation') }

        it 'sends the no reserved session message' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          subject
        end
      end

      context 'when the user session has been canceled' do
        let(:state) { :canceled }

        let(:expected_message) { I18n.t('notifier.sonar.no_session_booked') }

        it 'sends the no session booked message' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          subject
        end
      end
    end

    context 'when the message is negative' do
      let(:text) { %w[no n].sample }
      let(:expected_message) do
        I18n.t('notifier.sonar.no_more_sonar_cancellation',
               frontend_url: ENV.fetch('FRONTENT_URL', nil))
      end

      it 'sends the cancellation message' do
        expect(SonarService).to receive(:send_message).with(user, expected_message).once

        subject
      end

      context 'when the user does not have any session' do
        before { user_session.destroy! }

        let(:expected_message) { I18n.t('notifier.sonar.no_session_booked') }

        it 'sends the no session booked message' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          subject
        end
      end
    end

    context 'when the message is not negative nor positive' do
      let(:text) { 'anything' }
      let(:expected_message) { I18n.t('notifier.sonar.unreadable_text') }

      it 'sends the cancellation message' do
        expect(SonarService).to receive(:send_message).with(user, expected_message).once

        subject
      end
    end
  end
end
