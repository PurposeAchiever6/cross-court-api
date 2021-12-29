require 'rails_helper'

describe SessionReminderQuery do
  let(:reminder_ready_query) { SessionReminderQuery.new(RefereeSession.all.future.unconfirmed) }
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
    context 'when there are no referee_sessions in 24 hours' do
      it 'returns no referee_sessions' do
        expect(reminder_ready_query.in_24_hours).to eq([])
      end
    end

    context 'when there are referee_sessions in 24 hours' do
      let(:s1) { create(:session, time: los_angeles_time) }
      let(:s2) { create(:session, time: los_angeles_time + 1.hour) }
      let!(:referee_session1) { create(:referee_session, session: s1, date: los_angeles_date) }
      let!(:referee_session2) do
        create(:referee_session, session: s1, date: los_angeles_date + 1.day)
      end
      let!(:referee_session3) do
        create(:referee_session, session: s2, date: los_angeles_date + 1.day)
      end

      it 'returns only one referee_sessions' do
        expect(reminder_ready_query.in_24_hours.count).to eq(1)
      end

      it 'returns the right referee_sessions' do
        expect(reminder_ready_query.in_24_hours[0].id).to eq(referee_session2.id)
      end
    end
  end

  describe '.in' do
    let(:s1) { create(:session, time: los_angeles_time + 12.hours) }
    let(:s2) { create(:session, time: los_angeles_time + 7.hours) }
    let!(:referee_session1) do
      create(:referee_session, session: s1, date: los_angeles_date + 12.hours)
    end
    let!(:referee_session2) do
      create(:referee_session, session: s2, date: los_angeles_date + 7.hours)
    end
    let!(:referee_session3) { create(:referee_session, session: s2, date: 2.days.from_now) }

    describe 'in 12 hours' do
      it 'returns only one referee_session' do
        expect(reminder_ready_query.in(12).count).to eq(1)
      end

      it 'returns the right referee_session' do
        expect(reminder_ready_query.in(12)[0][:id]).to eq(referee_session1.id)
      end
    end
  end
end
