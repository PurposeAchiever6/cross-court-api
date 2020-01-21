require 'rails_helper'

describe UnconfirmedSessionsQuery do
  let(:unconfirmed_sessions_query) { UnconfirmedSessionsQuery.new }
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

  describe '.ready_to_cancel' do
    context 'when there are no user_sessions ready to cancel' do
      it 'returns no user_sessions' do
        expect(unconfirmed_sessions_query.ready_to_cancel).to be_empty
      end
    end

    context 'when there are user_sessions ready to cancel' do
      let(:s1)             { create(:session, time: los_angeles_time) }
      let!(:user_session1) { create(:user_session, session: s1, date: los_angeles_date) }
      let!(:user_session2) do
        create(:user_session, state: :confirmed, session: s1, date: los_angeles_date)
      end
      let!(:user_session3) { create(:user_session, session: s1, date: los_angeles_date + 1.day) }

      it 'returns only one user_sessions' do
        expect(unconfirmed_sessions_query.ready_to_cancel.count).to eq(1)
      end

      it 'returns the right user_sessions' do
        expect(unconfirmed_sessions_query.ready_to_cancel[0][:id]).to eq(user_session1.id)
      end
    end
  end
end
