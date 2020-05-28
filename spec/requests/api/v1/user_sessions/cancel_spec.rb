require 'rails_helper'

describe 'PUT api/v1/user_sessions/:user_session_id/cancel' do
  let(:los_angeles_time) do
    Time.zone.local_to_utc(Time.current.in_time_zone('America/Los_Angeles'))
  end

  before do
    allow_any_instance_of(SlackService).to receive(:session_canceled_in_time).and_return(1)
    allow_any_instance_of(SlackService).to receive(:session_canceled_out_of_time).and_return(1)
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  let(:user) { create(:user) }

  subject do
    put api_v1_user_session_cancel_path(user_session), headers: auth_headers, as: :json
  end

  context 'when in valid cancellation time' do
    let(:session) do
      create(:session, :daily, time: los_angeles_time + Session::CANCELLATION_PERIOD + 1.minute)
    end
    let!(:user_session) { create(:user_session, user: user, session: session) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'changes the user_session state to canceled' do
      expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled')
    end

    it 'reimburses the credit to the user' do
      expect { subject }.to change { user.reload.credits }.from(0).to(1)
    end

    it 'sets user_session credit_reimbursed to true' do
      expect { subject }.to change { user_session.reload.credit_reimbursed }.from(false).to(true)
    end

    it 'calls the slack service session_canceled_in_time method' do
      expect_any_instance_of(SlackService).to receive(:session_canceled_in_time).and_return(1)
      subject
    end
  end

  context 'when not in valid cancellation time' do
    let(:session) do
      create(:session, :daily, time: los_angeles_time + Session::CANCELLATION_PERIOD - 1.minute)
    end
    let!(:user_session) { create(:user_session, user: user, session: session) }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'changes the user_session state' do
      expect { subject }.to change { user_session.reload.state }.from('reserved').to('canceled')
    end

    it "doesn't reimburse the credit to the user" do
      expect { subject }.not_to change { user.reload.credits }
    end

    it 'calls the slack service session_canceled_out_of_time method' do
      expect_any_instance_of(SlackService).to receive(:session_canceled_out_of_time).and_return(1)
      subject
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
