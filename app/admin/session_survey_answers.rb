ActiveAdmin.register SessionSurveyAnswer do
  menu label: 'Answers', parent: 'Session Survey'
  actions :index, :show, :destroy

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
