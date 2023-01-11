require 'rails_helper'

describe 'POST api/v1/sessions/:session_id/user_sessions' do
  let!(:user) do
    create(
      :user,
      credits: 1,
      reserve_team:,
      flagged:,
      active_subscription:,
      scouting_credits:
    )
  end
  let!(:location) { create(:location, max_sessions_booked_per_day:) }
  let!(:session) do
    create(
      :session,
      :daily,
      location:,
      is_open_club:,
      skill_session:,
      all_skill_levels_allowed:,
      members_only:
    )
  end

  let(:max_sessions_booked_per_day) { nil }
  let(:flagged) { false }
  let(:reserve_team) { false }
  let(:date) { 1.day.from_now }
  let(:is_open_club) { false }
  let(:skill_session) { false }
  let(:all_skill_levels_allowed) { true }
  let(:members_only) { false }
  let(:params) { { date: date.strftime(Session::DATE_FORMAT) } }
  let(:active_subscription) { nil }
  let(:scouting_credits) { rand(1..5) }

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
         params:,
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
    expect { subject }.to have_enqueued_job(ActionMailer::MailDeliveryJob).on_queue('default')
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
      session.update!(time:)
    end

    it 'confirms the session automatically' do
      subject
      expect(UserSession.first.state).to eq('confirmed')
    end

    it 'calls the sonar service send_message method' do
      expect(SonarService).to receive(:send_message).and_return(1)
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
    let!(:user_session) { create_list(:user_session, 15, session:, date:) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it "doesn't create the user_session" do
      expect { subject }.not_to change(UserSession, :count)
    end
  end

  context 'when user has reached the number of sessions booked per day' do
    let(:max_sessions_booked_per_day) { 1 }
    let(:user_session_state) { :reserved }
    let(:user_session_date) { date }

    let!(:another_session) { create(:session, :daily, location:) }
    let!(:user_session) do
      create(
        :user_session,
        session: another_session,
        user:,
        date: user_session_date,
        state: user_session_state
      )
    end

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns correct error message' do
      subject
      expect(json[:error]).to eq(
        'Unfortunately, we had to limit the number of sessions members can book in a day ' \
        "in order to fulfill member demand\n"
      )
    end

    it "doesn't create the user_session" do
      expect { subject }.not_to change(UserSession, :count)
    end

    context 'when the other user session has been canceled' do
      let(:user_session_state) { :canceled }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }
    end

    context 'when the user session is not on the same day' do
      let(:user_session_date) { date + 1.day }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }
    end
  end

  context 'when session is open club' do
    let(:is_open_club) { true }

    context 'when is a member' do
      let(:active_subscription) { create(:subscription) }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }
    end

    context 'when is not a member' do
      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it { expect { subject }.not_to change(UserSession, :count) }
    end
  end

  context 'when the session is not for all skill levels' do
    let(:all_skill_levels_allowed) { false }

    before do
      session.skill_level.update!(min: 5, max: 7)
      user.update!(skill_rating: 3)
    end

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns correct error message' do
      subject
      expect(json[:error]).to eq("Can not reserve this session if it's outside user's skill level")
    end

    it "doesn't create the user_session" do
      expect { subject }.not_to change(UserSession, :count)
    end

    context 'when the user is advanced' do
      before { user.update(skill_rating: 5) }

      it 'enrolls the user to the session' do
        expect { subject }.to change { user.reload.sessions.count }.from(0).to(1)
      end
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
      expect(json[:error]).to eq I18n.t('api.errors.user_sessions.not_enough_credits')
    end
  end

  context 'when user has a paused subscription' do
    before { create(:subscription, user:, status: :paused) }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it "doesn't create the user_session" do
      expect { subject }.not_to change(UserSession, :count)
    end
  end

  context 'when the user is from the reserve team' do
    let(:reserve_team) { true }
    before { ENV['RESERVE_TEAM_RESERVATIONS_LIMIT'] = '1' }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    context 'when the session is not allowed for reserve team members' do
      let!(:user_session) { create(:user_session, session:, date:) }

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'raises an error' do
        subject
        expect(json[:error]).to eq I18n.t('api.errors.sessions.reserve_team_not_allowed')
      end
    end
  end

  context 'when the user flagged' do
    let(:flagged) { true }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'raises an error' do
      subject
      expect(json[:error]).to eq I18n.t('api.errors.users.flagged')
    end
  end

  context 'when user reserves a shooting machine' do
    let!(:shooting_machine) { create(:shooting_machine, session:) }

    before { params[:shooting_machine_id] = shooting_machine.id }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it { expect { subject }.not_to change(ShootingMachineReservation, :count) }

    context 'when session is open club' do
      let!(:payment_method) { create(:payment_method, user:, default: true) }
      let!(:active_subscription) { create(:subscription) }
      let(:is_open_club) { true }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }

      context 'when the shooting machine has already been reserved' do
        let!(:user_session) { create(:user_session, session:, date:) }
        let!(:shooting_machine_reservation) do
          create(
            :shooting_machine_reservation,
            shooting_machine:,
            user_session:
          )
        end

        it 'returns bad request' do
          subject
          expect(response).to have_http_status(:bad_request)
        end

        it 'returns correct error message' do
          subject
          expect(json[:error]).to eq('The shooting machine has already been reserved')
        end

        it { expect { subject }.not_to change(ShootingMachineReservation, :count) }
      end
    end
  end

  context 'when session is only for members' do
    let(:members_only) { true }

    it 'returns bad request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns correct error message' do
      subject
      expect(json[:error]).to eq('The session is only for members')
    end

    context 'when user is a member' do
      let(:active_subscription) { create(:subscription) }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.to change(UserSession, :count).by(1) }
    end
  end

  context 'when user want to use his scouting credit' do
    let(:scouting) { true }

    before { params[:scouting] = scouting }

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it { expect { subject }.to change { user.reload.scouting_credits }.by(-1) }

    context 'when scouting parameter is empty' do
      let(:scouting) { [false, nil].sample }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end

    context 'when session is open club' do
      let(:is_open_club) { true }
      let(:active_subscription) { create(:subscription) }

      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end

    context 'when session is a skill session' do
      let(:skill_session) { true }

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns correct error message' do
        subject
        expect(json[:error]).to eq('The session is not valid for scouting')
      end

      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end

    context 'when the user does not have any scouting credit' do
      let(:scouting_credits) { 0 }

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns correct error message' do
        subject
        expect(json[:error]).to eq('Not enough scouting sessions. Please buy one')
      end

      it { expect { subject }.not_to change { user.reload.scouting_credits } }
    end
  end
end
