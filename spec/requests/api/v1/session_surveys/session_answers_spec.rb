require 'rails_helper'

describe 'POST api/v1/session_surveys/answers' do
  let(:user)            { create(:user) }
  let(:user_session)    { create(:user_session) }
  let(:session_survey_question) { create(:session_survey_question) }

  let(:params) do
    {
      session_answer: {
        answer: 'This is the answer!',
        session_survey_question_id: session_survey_question.id
      }
    }
  end

  subject do
    post answers_api_v1_session_surveys_path, params: params, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  context 'when the user has an user session' do
    before { create(:user_session, user: user) }

    it 'creates the answer' do
      expect { subject }.to change(SessionSurveyAnswer, :count).by(1)
    end
  end
end
