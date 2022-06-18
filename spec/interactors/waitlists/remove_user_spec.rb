require 'rails_helper'

describe Waitlists::RemoveUser do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:session) { create(:session) }
    let!(:user_session_waitlist) do
      create(
        :user_session_waitlist,
        session: session,
        user: user,
        date: session.start_time,
        state: state
      )
    end

    let(:date) { session.start_time }
    let(:state) { :pending }

    subject { Waitlists::RemoveUser.call(session: session, user: user, date: date) }

    it { expect { subject }.to change(UserSessionWaitlist, :count).by(-1) }

    context 'when the user is not in the waitlist for that date' do
      let(:date) { session.start_time + 1.day }

      it { expect { subject }.to raise_error(UserNotInWaitlistException) }
      it { expect { subject rescue nil }.not_to change(UserSessionWaitlist, :count) }
    end

    context 'when the user session waitlist does not exist' do
      before { user_session_waitlist.destroy }

      it { expect { subject }.to raise_error(UserNotInWaitlistException) }
      it { expect { subject rescue nil }.not_to change(UserSessionWaitlist, :count) }
    end

    context 'if the user has already made it off the waitlist' do
      let(:state) { :success }

      it { expect { subject }.to raise_error(UserNotInWaitlistException) }
      it { expect { subject rescue nil }.not_to change(UserSessionWaitlist, :count) }
    end
  end
end
