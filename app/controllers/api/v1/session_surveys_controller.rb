module Api
  module V1
    class SessionSurveysController < Api::V1::ApiController
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_user!

      def questions
        user_session_id = current_user.last_checked_in_user_session&.id

        already_answered = SessionSurveyAnswer.where(user_session_id: user_session_id).exists?

        @survey_questions = already_answered ? [] : SessionSurveyQuestion.enabled.all
      end

      def answers
        user_session_id = current_user.last_checked_in_user_session&.id

        return unless user_session_id

        SessionSurveyAnswer.create!(session_answer_params.merge!(user_session_id: user_session_id))
        create_bad_review_deal if bad_review?
      end

      private

      def session_answer_params
        params.require(:session_answer).permit(:answer, :session_survey_question_id)
      end

      def create_bad_review_deal
        ::ActiveCampaign::CreateDealJob.perform_later(
          ::ActiveCampaign::Deal::Event::BAD_REVIEW,
          current_user.id,
          {},
          ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
        )
      end

      def bad_review?
        answer = session_answer_params[:answer]
        question = SessionSurveyQuestion.find(session_answer_params[:session_survey_question_id])

        question.rate_type? && num_review?(answer.to_s) && answer.to_i < 3
      end

      def num_review?(str)
        Integer(str)
        true
      rescue ArgumentError, TypeError
        false
      end
    end
  end
end
