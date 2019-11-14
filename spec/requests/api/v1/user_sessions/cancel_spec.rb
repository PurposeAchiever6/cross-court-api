require 'rails_helper'

describe 'PUT api/v1/user_sessions/:user_session_id/cancel' do
  let(:user)    { create(:user) }
  let(:session) { create(:session) }

  subject do
    put api_v1_user_session_cancel_path(user_session),
        headers: auth_headers,
        as: :json
  end

  context 'with valid params' do
    let!(:user_session) { create(:user_session, user: user, session: session) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'changes the user_session state to canceled' do
      expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled')
    end
  end

  context "when the user_session_id doesn't exists" do
    let(:user_session) { 'not_found' }

    it 'returns not_found' do
      subject
      expect(response).to have_http_status(:not_found)
    end
  end
end
