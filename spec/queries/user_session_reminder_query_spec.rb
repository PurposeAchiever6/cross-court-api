require 'rails_helper'

describe UserSessionReminderQuery do
  let(:reminder_ready_query) { UserSessionReminderQuery.new }
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

  describe '.in_24_hours' do
    context 'when there are no user_sessions in 24 hours' do
      it 'returns no user_sessions' do
        expect(reminder_ready_query.in_24_hours).to eq([])
      end
    end

    context 'when there are user_sessions in 24 hours' do
      let(:s1)             { create(:session, time: los_angeles_time) }
      let(:s2)             { create(:session, time: los_angeles_time + 1.hour) }
      let!(:user_session1) { create(:user_session, session: s1, date: los_angeles_date) }
      let!(:user_session2) { create(:user_session, session: s1, date: los_angeles_date + 1.day) }
      let!(:user_session3) { create(:user_session, session: s2, date: los_angeles_date + 1.day) }

      it 'returns only one user_sessions' do
        expect(reminder_ready_query.in_24_hours.count).to eq(1)
      end

      it 'returns the right user_sessions' do
        expect(reminder_ready_query.in_24_hours[0].id).to eq(user_session2.id)
      end
    end
  end

  describe '.in' do
    let(:s1)             { create(:session, time: los_angeles_time + 8.hours) }
    let(:s2)             { create(:session, time: los_angeles_time + 7.hours) }
    let!(:user_session1) { create(:user_session, session: s1) }
    let!(:user_session2) { create(:user_session, session: s2) }
    let!(:user_session3) { create(:user_session, session: s2, date: 2.days.from_now) }

    describe 'in 8 hours' do
      it 'returns only one user_sessions' do
        expect(reminder_ready_query.in(8).count).to eq(1)
      end

      it 'returns the right user_session' do
        expect(reminder_ready_query.in(8)[0][:id]).to eq(user_session1.id)
      end
    end

    describe 'in 7 hours' do
      it 'returns only one user_sessions' do
        expect(reminder_ready_query.in(7).count).to eq(1)
      end

      it 'returns the right user_session' do
        expect(reminder_ready_query.in(7)[0][:id]).to eq(user_session2.id)
      end
    end

    describe 'in 6 hours' do
      it 'returns no user_sessions' do
        expect(reminder_ready_query.in(6).count).to eq(0)
      end
    end
  end
end
