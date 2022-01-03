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
      end

      private

      def session_answer_params
        params.require(:session_answer).permit(:answer, :session_survey_question_id)
      end
    end
  end
end
