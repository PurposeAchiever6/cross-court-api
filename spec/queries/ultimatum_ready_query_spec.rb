require 'rails_helper'

describe UltimatumReadyQuery do
  let(:ultimatum_ready_query) { UltimatumReadyQuery.new }
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end
  let(:los_angeles_date) { los_angeles_time.to_date }
  let(:cancellation_period) { ENV['CANCELLATION_PERIOD'].to_i.hours }
  let(:ultimatum_period) { ENV['ULTIMATUM_PERIOD'].to_i.hours }

  before do
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  describe '.confirmation_pending' do
    context 'when there are not unconfirmed user_sessions ultimatum pending' do
      it 'returns no user_sessions' do
        expect(ultimatum_ready_query.confirmation_pending).to eq([])
      end
    end

    context 'when there are unconfirmed user_sessions ultimatum pending' do
      let(:s1) do
        create(:session, time: los_angeles_time + cancellation_period + ultimatum_period)
      end
      let!(:user_session1) { create(:user_session, session: s1, date: los_angeles_date) }
      let!(:user_session2) { create(:user_session, session: s1, date: los_angeles_date + 1.day) }

      it 'returns only one user_sessions' do
        expect(ultimatum_ready_query.confirmation_pending.count).to eq(1)
      end

      it 'returns the right user_sessions' do
        expect(ultimatum_ready_query.confirmation_pending[0].id).to eq(user_session1.id)
      end
    end
  end
end
