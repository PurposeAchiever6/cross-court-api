require 'rails_helper'

describe 'GET api/v1/user_sessions' do
  let!(:user) { create(:user) }
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end

  subject do
    get api_v1_user_sessions_path, headers: auth_headers, as: :json
  end

  describe 'when the user has not resereved any session' do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns no user_sessions' do
      subject
      expect(json[:previous_sessions].count).to eq(0)
      expect(json[:upcoming_sessions].count).to eq(0)
    end
  end

  describe 'when the user has already been in sessions' do
    before do
      Timecop.freeze(los_angeles_time)
    end

    after do
      Timecop.return
    end

    let(:s1)             { create(:session, time: 1.hour.ago) }
    let(:s2)             { create(:session, time: 1.hour.from_now) }
    let!(:user_session1) { create(:user_session, session: s1, user:, date: 2.days.ago) }
    let!(:user_session2) { create(:user_session, session: s1, user:, date: 1.day.ago) }
    let!(:user_session3) { create(:user_session, session: s1, user:, date: Date.current) }
    let!(:user_session4) { create(:user_session, session: s2, user:, date: Date.current) }
    let!(:user_session5) { create(:user_session, session: s1, user:, date: 1.day.from_now) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns user_sessions' do
      subject
      expect(json[:previous_sessions].count).to eq(3)
      expect(json[:upcoming_sessions].count).to eq(2)
      expect(json[:sem_upcoming_sessions].count).to eq(0)
    end
  end

  context 'when the user is a sem' do
    before do
      user.update!(is_sem: true, is_referee: true)
    end

    context 'when the session is not in starting time' do
      let(:s1)           { create(:session, :daily, time: los_angeles_time) }
      let(:s2)           { create(:session, :daily, time: los_angeles_time) }
      let!(:sem_session) { create(:sem_session, session: s1, user:, date: 2.days.from_now) }
      let!(:referee_session1) do
        create(:referee_session, session: s2, user:, date: 2.days.from_now)
      end

      it 'returns sem_upcoming_sessions' do
        subject
        expect(json[:sem_upcoming_sessions].count).to eq(2)
      end

      it 'returns in_start_time in false' do
        subject
        expect(json[:sem_upcoming_sessions][0][:in_start_time]).to be(false)
      end

      context 'when the user is also the referee' do
        let!(:referee_session2) do
          create(:referee_session, session: s1, user:, date: 2.days.from_now)
        end

        it 'returns only two upcoming_sessions' do
          subject
          expect(json[:sem_upcoming_sessions].count).to eq(2)
        end
      end
    end

    context 'when the session is in the starting time' do
      let(:s1)           { create(:session, time: los_angeles_time) }
      let!(:sem_session) { create(:sem_session, session: s1, user:, date: Date.current) }

      it 'returns sem_upcoming_sessions' do
        subject
        expect(json[:sem_upcoming_sessions].count).to eq(1)
      end

      it 'returns in_start_time in true' do
        subject
        expect(json[:sem_upcoming_sessions][0][:in_start_time]).to be(true)
      end
    end
  end
end
