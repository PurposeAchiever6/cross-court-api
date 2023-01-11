require 'rails_helper'

describe 'GET api/v1/session_surveys/questions' do
  let(:user) { create(:user) }
  let!(:enabled_questions_count) { rand(1..5) }
  let!(:questions_count) { rand(1..5) }
  let!(:enabled_questions) do
    create_list(:session_survey_question, enabled_questions_count, is_enabled: true)
  end
  let!(:disabled_questions) do
    create_list(:session_survey_question, questions_count, is_enabled: false)
  end
  let!(:user_session) { create(:user_session, user:, checked_in: true) }

  let(:params) { { user_session_id: user_session.id } }

  subject do
    get questions_api_v1_session_surveys_path, params:, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  context 'when the user did not answered yet for the session' do
    it 'returns the enabled questions' do
      subject
      expect(json[:survey_questions].count).to eq(enabled_questions_count)
    end
  end

  context 'when the user did answered for the session' do
    before { create(:session_survey_answer, user_session:) }

    it 'returns an empty array' do
      subject
      expect(json[:survey_questions].count).to eq(0)
    end
  end
end
