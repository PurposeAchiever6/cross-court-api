require 'rails_helper'

describe Sessions::TimeoutWaitlistsJob do
  describe '#perform' do
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }
    let!(:location) { create(:location) }
    let!(:session) { create(:session, time: session_time) }
    let!(:waitlist_item_1) do
      create(:user_session_waitlist, user: user_1, session: session, date: date)
    end
    let!(:waitlist_item_2) do
      create(:user_session_waitlist, user: user_2, session: session, date: date)
    end
    let!(:waitlist_item_3) do
      create(:user_session_waitlist, user: user_1, session: session, date: date + 1.day)
    end

    let(:current_time) { Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)) }
    let(:date) { current_time.to_date }
    let(:session_time) { current_time + UserSessionWaitlist::MINUTES_TOLERANCE - 1.minute }

    before { allow(SendSonar).to receive(:message_customer) }

    subject { Sessions::TimeoutWaitlistsJob.perform_now }

    it 'sends user_1 and user_2 the correct SMS message' do
      expect(SonarService).to receive(:send_message).with(
        user_1,
        /unfortunately we couldn't get you off the waitlist for today/
      )
      expect(SonarService).to receive(:send_message).with(
        user_2,
        /unfortunately we couldn't get you off the waitlist for today/
      )

      subject
    end

    it 'updates waitlist_item_1 state' do
      expect { subject }.to change { waitlist_item_1.reload.state }.from('pending').to('timeout')
    end

    it 'updates waitlist_item_2 state' do
      expect { subject }.to change { waitlist_item_2.reload.state }.from('pending').to('timeout')
    end

    it { expect { subject }.not_to change { waitlist_item_3.reload.state } }

    context 'when session time is inside the waitlist tolerance window' do
      let(:session_time) { current_time + UserSessionWaitlist::MINUTES_TOLERANCE + 1.minute }

      it 'does not send any SMS message' do
        expect(SonarService).not_to receive(:send_message)
        subject
      end

      it { expect { subject }.not_to change { waitlist_item_1.reload.state } }
      it { expect { subject }.not_to change { waitlist_item_2.reload.state } }
      it { expect { subject }.not_to change { waitlist_item_3.reload.state } }
    end
  end
end
