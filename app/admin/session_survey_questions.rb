ActiveAdmin.register SessionSurveyQuestion do
  menu label: 'Questions', parent: 'Session Survey'
  permit_params :question, :is_enabled, :is_mandatory

  form do |f|
    f.inputs 'Survey question' do
      f.input :question
      f.input :is_enabled
      f.input :is_mandatory
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :question
    column :is_enabled
    column :is_mandatory

    actions
  end

  show do
    attributes_table do
      row :question
      row :is_enabled
      row :is_mandatory
    end
  end
end
