class AddTypeToSessionSurveyQuestion < ActiveRecord::Migration[6.0]
  def change
    add_column :session_survey_questions, :type, :integer
    add_index :session_survey_questions, :type
  end
end
