require 'rails_helper'

describe 'DELETE api/v1/session_guests/:id' do
  let(:user) { create(:user) }
  let(:user_session) { create(:user_session, user:) }
  let!(:session_guest) { create(:session_guest, user_session:) }

  let(:params) { { user_session_id: user_session.id } }

  subject do
    delete api_v1_session_guest_path(id: session_guest.id),
           headers: auth_headers,
           params:,
           as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it { expect { subject }.to change { session_guest.reload.state }.from('reserved').to('canceled') }

  it { expect { subject }.to have_enqueued_job(::Sonar::SendMessageJob) }
end
