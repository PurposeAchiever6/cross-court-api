ActiveAdmin.register PlayerEvaluation do
  menu label: 'Evaluations', parent: 'Player Evaluation', priority: 0

  permit_params :user_id, :date, evaluation: {}

  config.sort_order = 'date_desc'

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
    column :rating
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
      row :rating
      row :evaluation do |player_evaluation|
        simple_format(player_evaluation.evaluation_formatted)
      end
      row :date
      row :updated_at
      row :created_at
    end
  end

  controller do
    def new
      @player_evaluation = PlayerEvaluation.new(
        user_id: params[:user_id],
        date: Time.zone.today
      )
    end
  end
end
