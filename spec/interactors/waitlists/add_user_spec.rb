require 'rails_helper'

describe Waitlists::AddUser do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let!(:session) { create(:session, start_time: la_time.tomorrow) }
    let(:date) { session.start_time }

    subject { Waitlists::AddUser.call(session: session, user: user, date: date) }

    it { expect { subject }.to change(UserSessionWaitlist, :count).by(1) }

    context 'when there is no session for the date' do
      let(:date) { session.start_time + 1.day }

      it { expect { subject }.to raise_error(InvalidDateException) }
    end

    context 'when date is in the past' do
      let(:date) { Time.zone.today - 2.days }

      it { expect { subject }.to raise_error(InvalidDateException) }
    end

    context 'when user is already in the waitlist' do
      before { create(:user_session_waitlist, session: session, user: user, date: date) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
