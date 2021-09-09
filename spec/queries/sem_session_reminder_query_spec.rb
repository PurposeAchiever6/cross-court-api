require 'rails_helper'

describe SessionReminderQuery do
  let(:reminder_ready_query) { SessionReminderQuery.new(SemSession.all.future.unconfirmed) }
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
    context 'when there are no sem_sessions in 24 hours' do
      it 'returns no sem_sessions' do
        expect(reminder_ready_query.in_24_hours).to eq([])
      end
    end

    context 'when there are sem_sessions in 24 hours' do
      let(:s1)            { create(:session, time: los_angeles_time) }
      let(:s2)            { create(:session, time: los_angeles_time + 1.hour) }
      let!(:sem_session1) { create(:sem_session, session: s1, date: los_angeles_date) }
      let!(:sem_session2) { create(:sem_session, session: s1, date: los_angeles_date + 1.day) }
      let!(:sem_session3) { create(:sem_session, session: s2, date: los_angeles_date + 1.day) }

      it 'returns only one sem_sessions' do
        expect(reminder_ready_query.in_24_hours.count).to eq(1)
      end

      it 'returns the right sem_sessions' do
        expect(reminder_ready_query.in_24_hours[0].id).to eq(sem_session2.id)
      end
    end
  end

  describe '.in' do
    let(:s1)            { create(:session, time: los_angeles_time + 12.hours) }
    let(:s2)            { create(:session, time: los_angeles_time + 7.hours) }
    let!(:sem_session1) { create(:sem_session, session: s1, date: los_angeles_date + 12.hours) }
    let!(:sem_session2) { create(:sem_session, session: s2, date: los_angeles_date + 7.hours) }
    let!(:sem_session3) { create(:sem_session, session: s2, date: 2.days.from_now) }

    describe 'in 12 hours' do
      it 'returns only one sem_session' do
        expect(reminder_ready_query.in(12).count).to eq(1)
      end

      it 'returns the right sem_session' do
        expect(reminder_ready_query.in(12)[0][:id]).to eq(sem_session1.id)
      end
    end
  end
end
