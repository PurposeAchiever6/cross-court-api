ActiveAdmin.register SessionSurvey do
  menu label: 'Session Surveys', parent: 'Feedbacks'

  actions :index, :show, :destroy

  includes :user

  filter :user
  filter :rate
  filter :feedback
  filter :created_at

  index do
    selectable_column
    id_column
    column :user
    column :rate
    column :feedback
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :user
      row :rate
      row :feedback
      row :created_at
      row :updated_at
    end
  end
end
