ActiveAdmin.register SessionSurveyQuestion do
  menu label: 'Session Survey Questions', parent: 'Feedbacks'
  permit_params :question, :is_enabled, :is_mandatory, :type

  form do |f|
    f.inputs 'Survey question' do
      f.input :question
      f.input :is_enabled
      f.input :is_mandatory
      f.input :type, as: :select, collection: SessionSurveyQuestion.types.keys, include_blank: false
    end
    actions
  end

  index do
    selectable_column
    id_column
    column :question
    column :is_enabled
    column :is_mandatory
    column :type

    actions
  end

  show do
    attributes_table do
      row :question
      row :is_enabled
      row :is_mandatory
      row :type
    end
  end
end
