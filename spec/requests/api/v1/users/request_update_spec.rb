require 'rails_helper'

describe 'PUT /api/v1/user/request_update' do
  let!(:user) { create(:user) }
  let(:skill_rating) { rand(1..5) }
  let(:reason) { 'Some reason' }

  let(:params) { { skill_rating:, reason: } }
  let(:request_headers) { auth_headers }

  subject do
    post request_update_api_v1_user_path,
         headers: request_headers,
         params:,
         as: :json
    response
  end

  it { is_expected.to be_successful }

  it { expect(subject.body).to be_empty }

  it { expect { subject }.to change(UserUpdateRequest, :count).by(1) }

  it 'sends update_request email' do
    expect { subject }.to have_enqueued_job(
      ActionMailer::MailDeliveryJob
    ).with('UserMailer', 'update_request', anything, anything)
  end

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(UserUpdateRequest, :count) }
    it { expect { subject }.not_to have_enqueued_job }
  end
end
