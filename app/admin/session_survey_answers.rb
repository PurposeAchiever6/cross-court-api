ActiveAdmin.register SessionSurveyAnswer do
  menu label: 'Session Survey Answers', parent: 'Feedbacks'
  actions :index, :show, :destroy
  includes :user, :session_survey_question

  filter :user
  filter :answer
  filter :session_survey_question

  index do
    selectable_column
    id_column
    column :answer
    column :session_survey_question
    column :user

    actions
  end

  show do
    attributes_table do
      row :answer
      row :session_survey_question
      row :user
    end
  end
end
