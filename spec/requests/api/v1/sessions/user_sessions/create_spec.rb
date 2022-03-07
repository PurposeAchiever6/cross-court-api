require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/user_sessions' do
  let!(:user) { create(:user, credits: 1) }
  let!(:session) { create(:session, :daily, is_open_club: is_open_club) } # Weekly today
  let(:date) { 1.day.from_now }
  let(:is_open_club) { false }
  let(:params) { { date: date.strftime(Session::DATE_FORMAT) } }

  before do
    ActiveCampaignMocker.new.mock
    allow_any_instance_of(SlackService).to receive(:session_booked).and_return(1)
    Timecop.freeze(Time.current.change(hour: 10))
  end

  after do
    Timecop.return
  end

  subject do
    post api_v1_session_user_sessions_path(session_id: session.id),
         headers: auth_headers,
         params: params,
         as: :json
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

  it 'calls the Active Campaign service' do
    expect { subject }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default')
  end

  it 'calls the Slack service' do
    expect_any_instance_of(SlackService).to receive(:session_booked).and_return(1)
    subject
  end

  it 'sends session booked email' do
    expect {
      SessionMailer.session_booked.deliver_later
    }.to have_enqueued_job.on_queue('mailers')
    subject
  end

  it "doesn't update user's free_session_state" do
    expect { subject }.not_to change { user.reload.free_session_state }
  end

  context 'when booking in the cancellation window' do
    it "doesn't confirm the user_session" do
      subject
      expect(UserSession.first.state).to eq('reserved')
    end
  end

  context 'when booking outside the cancellation time' do
    let(:time) do
      Time.zone.local_to_utc(
        Time.current.in_time_zone('America/Los_Angeles')
      ) + Session::CANCELLATION_PERIOD - 1.minute
    end
    let(:date) { time.to_date }

    before do
      allow(SonarService).to receive(:send_message).and_return(1)
      allow_any_instance_of(SlackService).to receive(:session_auto_confirmed).and_return(1)
      session.update!(time: time)
    end

    it 'confirms the session automatically' do
      subject
      expect(UserSession.first.state).to eq('confirmed')
    end

    it 'calls the sonar service send_message method' do
      expect(SonarService).to receive(:send_message).and_return(1)
      subject
    end

    it 'calls the slack service' do
      expect_any_instance_of(SlackService).to receive(:session_auto_confirmed)
      subject
    end
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

  context 'when session is open club' do
    let(:is_open_club) { true }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns correct error message' do
      subject
      expect(json[:error]).to eq('Can not reserve session for open club')
    end

    it "doesn't create the user_session" do
      expect { subject }.not_to change(UserSession, :count)
    end
  end

  context 'when user has been referred by other user' do
    let!(:other_user) { create(:user) }

    before { params[:referral_code] = other_user.referral_code }

    it 'increments the credits of the other user' do
      expect { subject }.to change { other_user.reload.credits }.by(1)
    end
  end

  context 'when the user is under 18' do
    let(:user) { create(:user, credits: 1, birthday: (Time.zone.today - 15.years)) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it "doesn't create the user_session" do
      expect { subject }.not_to change(UserSession, :count)
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
