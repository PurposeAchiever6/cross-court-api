ActiveAdmin.register FirstTimerSurvey do
  menu label: 'First Timers Surveys', parent: 'Feedbacks'
  actions :index, :show, :destroy
  includes :user

  index do
    selectable_column
    id_column
    column :user
    column :how_do_you_hear_about_us
    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table do
      row :user
      row :how_do_you_hear_about_us
      row :created_at
      row :updated_at
    end
  end
end
