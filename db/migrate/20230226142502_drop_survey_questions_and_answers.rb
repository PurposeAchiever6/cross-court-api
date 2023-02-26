class DropSurveyQuestionsAndAnswers < ActiveRecord::Migration[7.0]
  def up
    migrate_answers_to_session_survey_table

    drop_table :session_survey_questions
    drop_table :session_survey_answers
  end

  def down
    create_table :session_survey_questions do |t|
      t.string :question, null: false
      t.boolean :is_enabled, default: true
      t.boolean :is_mandatory, default: false
      t.integer :type
      t.timestamps
    end

    create_table :session_survey_answers do |t|
      t.string :answer
      t.references :session_survey_question
      t.references :user_session
      t.timestamps
    end
  end

  private

  def migrate_answers_to_session_survey_table
    return unless defined?(SessionSurveyAnswer)

    SessionSurveyAnswer.includes(:session_survey_question, :user_session, :user)
                       .order(id: :asc)
                       .find_each do |answer|
      survey = SessionSurvey.find_or_create_by!(
        user: answer.user,
        user_session: answer.user_session
      )

      answer_response = answer.answer
      question_type = answer.session_survey_question&.type

      if question_type == 'rate' && answer_response.present?
        survey.update!(
          rate: answer_response,
          created_at: answer.created_at,
          updated_at: answer.updated_at
        )
      end

      if question_type == 'open' && answer_response.present?
        survey.update!(
          feedback: answer_response,
          created_at: answer.created_at,
          updated_at: answer.updated_at
        )
      end
    end
  end
end
