require 'rails_helper'

describe 'POST api/v1/session_guests' do
  let(:guest_info) do
    {
      first_name: 'Mike',
      last_name: 'Lopez',
      phone_number: '+11342214334',
      email: 'mike@mail.com'
    }
  end

  let(:guests_allowed) { 1 }
  let(:guests_allowed_per_user) { 1 }

  before { ENV['MAX_REDEMPTIONS_BY_GUEST'] = '1' }

  let!(:session) do
    create(
      :session,
      guests_allowed:,
      guests_allowed_per_user:
    )
  end

  let!(:user) { create(:user) }
  let!(:user_session) { create(:user_session, session:, user:) }

  let(:params) do
    { guest_info:, user_session_id: user_session.id }
  end

  subject do
    post api_v1_session_guests_path, params:, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it { expect { subject }.to change(SessionGuest, :count).by(1) }

  it { expect { subject }.to have_enqueued_job(::Sonar::SendMessageJob) }

  context 'when guests_allowed is not set' do
    let(:guests_allowed) { nil }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
  end

  context 'when the session reaches the max guests' do
    let!(:another_user_session) { create(:user_session, session:) }
    let!(:session_guest) { create(:session_guest, user_session: another_user_session) }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
  end

  context 'when the user reaches the max guests' do
    let(:guests_allowed) { 2 }
    let!(:session_guest) { create(:session_guest, user_session:) }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
  end

  context 'when the guest has already been invited' do
    let(:guests_allowed) { 2 }
    let!(:session_guest) { create(:session_guest, phone_number: '+11342214334') }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it { expect { subject rescue nil }.not_to change(SessionGuest, :count) }
  end
end
