require 'rails_helper'

describe 'GET api/v1/sem/sessions/:id' do
  let(:today)    { Date.current }
  let!(:session) { create(:session) }
  let!(:user_sessions) do
    create_list(:user_session, 15, session:, date: today, state: :confirmed)
  end
  let(:params) { { date: today.to_s } }

  subject { get api_v1_sem_session_path(session), params:, headers: auth_headers, as: :json }

  describe 'when the user is a sem' do
    let!(:user)        { create(:user, :sem) }
    let!(:sem_session) { create(:sem_session, session:, user:) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'returns the session id' do
      subject
      expect(json[:session][:id]).to eq(session.id)
    end

    it 'returns the users that reserved the session' do
      subject
      expect(json[:users].count).to eq(15)
    end
  end

  describe 'when the user is not a sem' do
    let!(:user) { create(:user) }

    it 'returns error' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
