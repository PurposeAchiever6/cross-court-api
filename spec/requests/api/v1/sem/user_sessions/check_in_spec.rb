require 'rails_helper'

describe 'PUT api/v1/sem/user_sessions/check_in' do
  let(:user)          { create(:user, :sem) }
  let(:session)       { create(:session) }
  let(:user_sessions) { create_list(:user_session, 5, session: session) }
  let(:params)        { { ids: user_sessions.pluck(:id) } }

  before do
    allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
  end

  subject do
    put check_in_api_v1_sem_user_sessions_path, params: params, headers: auth_headers, as: :json
  end

  context 'with valid params' do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'checks in all user_sessions' do
      expect { subject }.to change { UserSession.where(checked_in: true).count }.from(0).to(5)
    end

    it 'calls the klaviyo service' do
      expect_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
      subject
    end
  end

  context 'when the user is not a sem' do
    before { user.update!(is_sem: false) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end
  end
end
