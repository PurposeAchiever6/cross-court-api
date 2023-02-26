require 'rails_helper'

describe 'POST api/v1/surveys/sessions' do
  let!(:user) { create(:user) }
  let!(:checked_in_user_session) { create(:user_session, user:, checked_in: true) }
  let!(:user_session) { create(:user_session, user:, checked_in: false) }

  let(:rate) { rand(1..5) }
  let(:feedback) { 'Some feedback' }

  let(:params) { { rate:, feedback: } }
  let(:request_headers) { auth_headers }

  subject do
    post api_v1_surveys_sessions_path,
         headers: request_headers,
         params:,
         as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect { subject }.to change(SessionSurvey, :count).by(1) }
  it { expect(subject.body).to be_empty }

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(SessionSurvey, :count) }
  end
end
