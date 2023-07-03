require 'rails_helper'

describe UserSessions::ForSelfCheckIn do
  describe '.call' do
    let(:user) { create(:user) }
    let(:time_zone) { 'America/Los_Angeles' }
    let(:los_angeles_time) { Time.zone.local_to_utc(Time.current.in_time_zone(time_zone)) }
    let(:location) { create(:location, time_zone:) }
    let(:location_id) { location.id }
    let(:date) { Date.current }
    let(:checked_in) { false }

    let(:session_1) { create(:session, time: los_angeles_time - 1.hour, location:) }
    let(:session_2) { create(:session, time: los_angeles_time + 30.minutes, location:) }
    let(:session_3) { create(:session, time: los_angeles_time + 1.hour, location:) }

    let!(:user_session_1) { create(:user_session, session: session_1, user:, date:, checked_in:) }
    let!(:user_session_2) { create(:user_session, session: session_2, user:, date:, checked_in:) }
    let!(:user_session_3) { create(:user_session, session: session_3, user:, date:, checked_in:) }

    before { Timecop.freeze }

    after { Timecop.return }

    subject { described_class.call(user:, location_id:) }

    it { expect(subject.user_sessions.length).to eq(2) }
    it { expect(subject.user_sessions.first.id).to eq(user_session_2.id) }
    it { expect(subject.user_sessions.second.id).to eq(user_session_3.id) }

    context 'when the user has not reserved any session' do
      before { UserSession.destroy_all }

      it { expect(subject.user_sessions.length).to eq(0) }
    end

    context 'when the sessions have been checked_in' do
      let(:checked_in) { true }

      it { expect(subject.user_sessions.length).to eq(0) }
    end

    context 'when the sessions are for another location' do
      let(:location_2) { create(:location, time_zone:) }
      let(:location_id) { location_2.id }

      it { expect(subject.user_sessions.length).to eq(0) }
    end

    context 'when the sessions are for another day' do
      let(:date) { Date.current + 1.day }

      it { expect(subject.user_sessions.length).to eq(0) }
    end
  end
end
