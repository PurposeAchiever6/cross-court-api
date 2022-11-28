ActiveAdmin.register PlayerEvaluation do
  menu label: 'Player Evaluations', parent: 'Users', priority: 6

  permit_params :user_id, :date, evaluation: {}

  includes :user

  filter :user
  filter :total_score
  filter :date

  form partial: 'form'

  index do
    selectable_column
    id_column
    column :user
    column :total_score
    column :evaluation do |player_evaluation|
      simple_format(player_evaluation.evaluation_formatted)
    end
    column :date

    actions
  end

  show do
    attributes_table do
      row :user
      row :total_score
      row :evaluation do |player_evaluation|
        simple_format(player_evaluation.evaluation_formatted)
      end
      row :date
      row :updated_at
      row :created_at
    end
  end
end
