class AddTimestampsToSessionSurveyAnswer < ActiveRecord::Migration[6.0]
  def change
    add_column :session_survey_answers, :created_at, :datetime
    add_column :session_survey_answers, :updated_at, :datetime
  end
end
