require 'rails_helper'

describe 'GET /api/v1/sessions/:session_id/user_sessions', type: :request do
  let(:user) { create(:user) }
  let!(:location) { create(:location) }
  let!(:session) { create(:session, location:) }

  let!(:user_session1) do
    create(:user_session, session:, date: Time.zone.today, checked_in: true)
  end
  let!(:user_session2) do
    create(:user_session, session:, date: Time.zone.today, checked_in: true)
  end
  let!(:user_session3) do
    create(:user_session, session:, date: 2.days.from_now, checked_in: true)
  end
  let!(:user_session4) do
    create(:user_session, session:, date: 2.days.from_now, checked_in: true)
  end

  let(:params) { {} }

  subject do
    get api_v1_session_user_sessions_path(session_id: session.id),
        headers: auth_headers,
        params:,
        as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  context 'when date is not passed' do
    it 'returns the users_sessions for today' do
      subject
      expect(json[:user_sessions].count).to eq(2)
    end
  end

  context 'when date is passed' do
    let(:params) { { date: 2.days.from_now.strftime('%d/%m/%Y') } }

    it 'returns the users_sessions for that day' do
      subject
      expect(json[:user_sessions].count).to eq(2)
    end
  end
end
