require 'rails_helper'

describe 'POST api/v1/surveys/first_timers' do
  let!(:user) { create(:user) }
  let(:how_did_you_hear_about_us) { 'Search Engine' }

  let(:params) { { how_did_you_hear_about_us: } }
  let(:request_headers) { auth_headers }

  subject do
    post api_v1_surveys_first_timers_path,
         headers: request_headers,
         params:,
         as: :json
    response
  end

  it { is_expected.to be_successful }
  it { expect { subject }.to change(FirstTimerSurvey, :count).by(1) }
  it { expect(subject.body).to be_empty }

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change(FirstTimerSurvey, :count) }
  end

  context 'when the user already has a FirstTimerSurvey' do
    let!(:first_timer_survey) { create(:first_timer_survey, user:) }

    it { expect { subject }.not_to change(FirstTimerSurvey, :count) }
  end
end
