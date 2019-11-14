require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/user_sessions' do
  let(:user)    { create(:user) }
  let(:session) { create(:session, :daily) } # Weekly today
  let(:date)    { Date.tomorrow }
  let(:params)  { { date: date.strftime(Session::DATE_FORMAT) } }

  subject do
    post api_v1_session_user_sessions_path(session_id: session.id),
         headers: auth_headers,
         params: params,
         as: :json
  end

  context "when the user haven't enrolled yet" do
    context 'with valid date' do
      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it 'enrolls the user to the session' do
        expect { subject }.to change { user.reload.sessions.count }.from(0).to(1)
      end
    end

    context 'with invalid date' do
      let(:date) { Date.yesterday }

      it 'returns bad_request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it "doesn't enroll the user to the session" do
        expect { subject }.not_to change { user.reload.sessions.count }
      end
    end
  end

  context 'when the user is already enrolled in the session' do
    let!(:user_session) { create(:user_session, user: user, session: session, date: date) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it "doesn't enroll the user in the session" do
      expect { subject }.not_to change { user.reload.sessions.count }
    end
  end
end
