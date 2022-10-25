require 'rails_helper'

describe UserSessions::ValidateDate do
  describe '.call' do
    subject { UserSessions::ValidateDate.call(user_session: user_session) }

    let(:user) { create(:user) }
    let(:session) { create(:session, :daily) }
    let(:la_time) { Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles')) }
    let(:user_session) do
      create(:user_session, user: user, session: session, date: date)
    end

    context 'when the date is correct' do
      let(:date) { la_time.tomorrow }

      it { expect { subject }.to change(UserSession, :count) }
    end

    context 'when the date is incorrect' do
      let(:date) { la_time.yesterday }

      it { expect { subject }.to raise_error(InvalidDateException) }
    end
  end
end
