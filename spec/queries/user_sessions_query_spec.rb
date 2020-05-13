require 'rails_helper'

describe UserSessionsQuery do
  let(:user_sessions_query) { UserSessionsQuery.new }
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let(:los_angeles_date) { los_angeles_time.to_date }

  before do
    Timecop.freeze(los_angeles_time)
  end

  after do
    Timecop.return
  end

  describe '.finished_cancellation_time' do
    context 'when there are no user_sessions ready to confirm' do
      it 'returns no user_sessions' do
        expect(user_sessions_query.finished_cancellation_time).to be_empty
      end
    end

    context 'when there are user_sessions ready to cancel' do
      let(:s1)             { create(:session, time: los_angeles_time) }
      let!(:user_session1) { create(:user_session, session: s1, date: los_angeles_date) }
      let!(:user_session2) { create(:user_session, session: s1, date: los_angeles_date + 1.day) }

      it 'returns only one user_sessions' do
        expect(user_sessions_query.finished_cancellation_time.count).to eq(1)
      end

      it 'returns the right user_sessions' do
        expect(user_sessions_query.finished_cancellation_time[0][:id]).to eq(user_session1.id)
      end
    end
  end
end
