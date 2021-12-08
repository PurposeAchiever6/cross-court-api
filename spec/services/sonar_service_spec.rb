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

    let!(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:user) { create(:user) }
    let!(:la_date) { la_time.to_date }

    let!(:time_24) { la_time.strftime(Session::TIME_FORMAT) }
    let!(:session) { create(:session, :daily, time: time_24) }
    let!(:user_session) { create(:user_session, date: la_date.tomorrow, session: session, user: user) }

    subject { SonarService.message_received(user, text) }

    context 'when the message is positive' do
      let(:text) { %w[yes y].sample }
      let(:expected_message) do
        I18n.t(
          'notifier.session_confirmed',
          name: user.first_name,
          when: 'tomorrow',
          time: user_session.time.strftime(Session::TIME_FORMAT),
          location: "#{user_session.location.name} (#{user_session.location.address})",
          invite_friend: I18n.t('notifier.invite_friend_msg', link: user_session.invite_link)
        )
      end

      it { expect { subject }.to change { user_session.reload.state }.from('reserved').to('confirmed') }

      it 'sends the confirmation message' do
        expect(SonarService).to receive(:send_message).with(user, expected_message).once

        subject
      end

      context 'when the user does not have any session' do
        before { user_session.destroy! }

        let(:expected_message) { I18n.t('notifier.no_session_booked') }

        it 'sends the no session booked message' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          subject
        end
      end
    end

    context 'when the message is negative' do
      let(:text) { %w[no n].sample }
      let(:expected_message) do
        I18n.t(
          'notifier.session_canceled_in_time',
          schedule_url: "#{ENV['FRONTENT_URL']}/locations"
        )
      end

      it { expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled') }

      it 'sends the cancelation message' do
        expect(SonarService).to receive(:send_message).with(user, expected_message).once

        subject
      end

      context 'when the user does not have any session' do
        before { user_session.destroy! }

        let(:expected_message) { I18n.t('notifier.no_session_booked') }

        it 'sends the no session booked message' do
          expect(SonarService).to receive(:send_message).with(user, expected_message).once

          subject
        end
      end
    end

    context 'when the message is not negative nor positive' do
      let(:text) { 'anything' }
      let(:expected_message) { I18n.t('notifier.unreadable_text') }

      it 'sends the cancelation message' do
        expect(SonarService).to receive(:send_message).with(user, expected_message).once

        subject
      end
    end
  end
end
