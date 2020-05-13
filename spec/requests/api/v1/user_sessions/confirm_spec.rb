require 'rails_helper'

describe 'PUT api/v1/user_sessions/:user_session_id/confirm' do
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end

  before do
    Timecop.freeze(Time.current)
    allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
  end

  after do
    Timecop.return
  end

  let(:user) { create(:user) }

  subject do
    put api_v1_user_session_confirm_path(user_session), headers: auth_headers, as: :json
  end

  context 'when in valid confirmation time' do
    let(:session)       { create(:session, :daily, time: los_angeles_time - 1.minute) }
    let!(:user_session) { create(:user_session, user: user, date: Date.tomorrow, session: session) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'changes the user_session state to confirmed' do
      expect { subject }.to change { user_session.reload.state }.from('reserved').to('confirmed')
    end

    context 'when the user_session is canceled' do
      before do
        user_session.canceled!
      end

      it "doesn't change the user_session state" do
        expect { subject }.not_to change { user_session.reload.state }
      end
    end
  end

  context 'when not in valid confirmation time' do
    context 'when the session is in more the 24 hours' do
      let(:session) { create(:session, :daily) }
      let!(:user_session) do
        create(:user_session, user: user, date: 1.day.from_now, session: session)
      end

      it "doesn't change the user_session state" do
        expect { subject }.not_to change { user_session.reload.state }
      end
    end

    context 'when the session is in the past' do
      let(:session) { create(:session, :daily, start_time: Date.yesterday) }
      let!(:user_session) do
        create(:user_session, user: user, date: Date.yesterday, session: session)
      end

      it "doesn't change the user_session state" do
        expect { subject }.not_to change { user_session.reload.state }
      end
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
