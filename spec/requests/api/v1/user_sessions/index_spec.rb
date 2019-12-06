require 'rails_helper'

describe 'GET api/v1/user_sessions' do
  let!(:user) { create(:user) }

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
      Timecop.freeze(Time.current.change(hour: 12))
    end

    after do
      Timecop.return
    end

    let(:s1)             { create(:session, time: Time.current - 1.hour) }
    let(:s2)             { create(:session, time: Time.current + 1.hour) }
    let!(:user_session1) { create(:user_session, session: s1, user: user, date: 2.days.ago) }
    let!(:user_session2) { create(:user_session, session: s1, user: user, date: 1.day.ago) }
    let!(:user_session3) { create(:user_session, session: s1, user: user, date: Date.current) }
    let!(:user_session4) { create(:user_session, session: s2, user: user, date: Date.current) }
    let!(:user_session5) { create(:user_session, session: s1, user: user, date: 1.day.from_now) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns user_sessions' do
      subject
      expect(json[:previous_sessions].count).to eq(3)
      expect(json[:upcoming_sessions].count).to eq(2)
    end
  end
end
