require 'rails_helper'

describe 'POST api/v1/session_surveys/answers' do
  let(:user)            { create(:user) }
  let(:user_session)    { create(:user_session) }
  let(:type) { %w[rate open].sample }
  let(:session_survey_question) { create(:session_survey_question, type: type) }
  let(:answer) { 'This is the answer!' }

  let(:params) do
    {
      session_answer: {
        answer: answer,
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
    before { create(:user_session, user: user, checked_in: true) }

    it 'creates the answer' do
      expect { subject }.to change(SessionSurveyAnswer, :count).by(1)
    end

    context 'when is rate type' do
      let(:type) { 'rate' }

      context 'when the review is less than 3 stars' do
        let(:answer) { %w[1 2].sample }

        it 'creates a bad review deal' do
          expect {
            subject
          }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default').with(
            ::ActiveCampaign::Deal::Event::BAD_REVIEW,
            user.id,
            {},
            ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
          )
        end
      end

      context 'when the review is equal or more than 3 stars' do
        let(:answer) { %w[3 4 5].sample }

        it 'creates a bad review deal' do
          expect {
            subject
          }.not_to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default')
        end
      end
    end
  end
end
