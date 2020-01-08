require 'rails_helper'

describe 'GET api/v1/sem/sem_sessions' do
  let(:user)    { create(:user, :sem) }
  let(:session) { create(:session) }

  subject { get api_v1_sem_sem_sessions_path, headers: auth_headers, as: :json }

  context "when the user doesn't have any upcoming sessions" do
    it 'returns no sem_sessions' do
      subject
      expect(json[:upcoming_sessions].count).to eq(0)
    end
  end

  context 'when the user has an upcoming session' do
    let!(:sem_session) { create(:sem_session, user: user, session: session) }

    it 'returns the sem_session' do
      subject
      expect(json[:upcoming_sessions][0][:id]).to eq(sem_session.id)
    end
  end

  context 'when the user is not a sem' do
    let(:user) { create(:user) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end
end
