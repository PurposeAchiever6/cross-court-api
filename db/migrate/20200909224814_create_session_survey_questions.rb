class CreateSessionSurveyQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :session_survey_questions do |t|
      t.string :question, null: false
      t.boolean :is_enabled, default: true
      t.boolean :is_mandatory, default: false
    end
  end
end
