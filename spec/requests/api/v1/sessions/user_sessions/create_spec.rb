require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/user_sessions' do
  let(:user)    { create(:user) }
  let(:session) { create(:session) }

  subject do
    post api_v1_session_user_sessions_path(session_id: session.id), headers: auth_headers, as: :json
  end

  context "when the user haven't enrolled yet" do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'enrolls the user to the session' do
      expect { subject }.to change { user.reload.sessions.count }.from(0).to(1)
    end
  end

  context 'when the user have already enrolled in the session' do
    let!(:user_session) { create(:user_session, user: user, session: session) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it "doesn't enroll the user in the session" do
      expect { subject }.not_to change { user.reload.sessions.count }
    end
  end
end
