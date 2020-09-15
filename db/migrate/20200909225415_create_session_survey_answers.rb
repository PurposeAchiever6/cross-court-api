class CreateSessionSurveyAnswers < ActiveRecord::Migration[6.0]
  def change
    create_table :session_survey_answers do |t|
      t.string :answer
      t.references :session_survey_question
      t.references :user_session
    end
  end
end
