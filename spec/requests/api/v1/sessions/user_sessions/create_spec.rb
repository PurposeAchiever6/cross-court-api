require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/user_sessions' do
  let(:user)    { create(:user, credits: 1) }
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

      it 'consumes one credit from the user' do
        expect { subject }.to change { user.reload.credits }.from(1).to(0)
      end

      it "doesn't update user's free_session_state" do
        expect { subject }.not_to change { user.reload.free_session_state }
      end

      it "doesn't confirm the user_session" do
        subject
        expect(UserSession.first.state).to eq('reserved')
      end

      context 'when using the free session' do
        before do
          user.free_session_state = :claimed
          user.free_session_payment_intent = 'pi_123456789'
          user.save!
        end

        it 'returns success' do
          subject
          expect(response).to be_successful
        end

        it 'enrolls the user to the session' do
          expect { subject }.to change { user.reload.sessions.count }.from(0).to(1)
        end

        it 'consumes one credit from the user' do
          expect { subject }.to change { user.reload.credits }.from(1).to(0)
        end

        it 'updates user free_session_state' do
          expect { subject }.to change { user.reload.free_session_state }.from('claimed').to('used')
        end
      end

      context 'when the session is full' do
        let!(:user_session) { create_list(:user_session, 15, session: session, date: date) }

        it 'returns bad request' do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it "doesn't create the user_session" do
          expect { subject }.not_to change(UserSession, :count)
        end
      end

      context 'when reserving in the confirmation time' do
        let(:date)    { Date.tomorrow }
        let(:session) do
          create(:session, :daily,
                 time: Time.current.in_time_zone('America/Los_Angeles') - 1.minute)
        end

        it 'confirms the session automatically' do
          subject
          expect(UserSession.first.state).to eq('confirmed')
        end
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

  context "when the user doesn't have credits" do
    before { user.update!(credits: 0) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'raises an error' do
      subject
      expect(json[:error]).to eq I18n.t('api.errors.user_session.not_enough_credits')
    end
  end
end
