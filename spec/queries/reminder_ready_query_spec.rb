require 'rails_helper'

describe ReminderReadyQuery do
  let(:reminder_ready_query) { ReminderReadyQuery.new }
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let(:los_angeles_date) { los_angeles_time.to_date }

  before do
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  describe '.tomorrow_user_sessions' do
    context 'when there are no user_sessions for tomorrow' do
      it 'returns no user_sessions' do
        expect(reminder_ready_query.tomorrow_user_sessions).to eq([])
      end
    end

    context 'when there are user_sessions for tomorrow' do
      let(:s1)             { create(:session, time: los_angeles_time) }
      let(:s2)             { create(:session, time: los_angeles_time + 1.hour) }
      let!(:user_session1) { create(:user_session, session: s1, date: los_angeles_date) }
      let!(:user_session2) { create(:user_session, session: s1, date: los_angeles_date + 1.day) }
      let!(:user_session3) { create(:user_session, session: s2, date: los_angeles_date + 1.day) }

      it 'returns only one user_sessions' do
        expect(reminder_ready_query.tomorrow_user_sessions.count).to eq(1)
      end

      it 'returns the right user_sessions' do
        expect(reminder_ready_query.tomorrow_user_sessions[0].id).to eq(user_session2.id)
      end
    end
  end
end
