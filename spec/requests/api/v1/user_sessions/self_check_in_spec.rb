require 'rails_helper'

describe 'PUT api/v1/user_sessions/self_check_in' do
  let(:user) { create(:user) }
  let(:location) { create(:location) }
  let(:location_id) { location.id }
  let(:session_location) { location }
  let(:session) { create(:session, location: session_location) }
  let!(:user_session_1) { create(:user_session, session:, checked_in: false, user:) }
  let!(:user_session_2) { create(:user_session, session:, checked_in: false, user:) }
  let(:user_session_ids) { [user_session_1.id, user_session_2.id] }
  let(:time) { Time.now.to_i }
  let(:crypt) do
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])
  end
  let(:msg) { crypt.encrypt_and_sign({ time:, location_id: }) }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  before { Timecop.freeze }

  after { Timecop.return }

  subject do
    put self_check_in_api_v1_user_sessions_path,
        headers: auth_headers,
        params: { user_session_ids:, qr_data: msg },
        as: :json
    response
  end

  it { is_expected.to be_successful }

  it { expect { subject }.to change { user_session_1.reload.checked_in }.from(false).to(true) }
  it { expect { subject }.to change { user_session_2.reload.checked_in }.from(false).to(true) }

  it do
    expect {
      subject
    }.to have_enqueued_job(
      ::Sessions::CheckInUsersJob
    ).once.with(user_session_ids, checked_in_at: time)
  end

  it do
    expect {
      subject
    }.to have_enqueued_job(::Sonar::FirstSessionSmsJob).once.with(user_session_ids)
  end

  context 'when the session is for another location' do
    let!(:session_location) { create(:location) }

    it { is_expected.to have_http_status(:bad_request) }
  end

  context 'when the qr data is invalid' do
    let(:msg) { 'invalid' }

    it { is_expected.to have_http_status(:bad_request) }
  end
end
