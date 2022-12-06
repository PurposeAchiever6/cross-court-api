ActiveAdmin.register PlayerEvaluationRatingRange do
  menu label: 'Ratings', parent: 'Player Evaluation', priority: 2

  permit_params :min_score, :max_score, :rating

  config.sort_order = 'rating_desc'

  index do
    selectable_column
    id_column
    column :min_score
    column :max_score
    column :rating

    actions
  end

  form do |f|
    f.inputs 'Player Evaluation Details' do
      f.input :min_score, min: 0
      f.input :max_score, min: 0
      f.input :rating, min: 0
    end

    f.actions
  end

  show do
    attributes_table do
      row :min_score
      row :max_score
      row :rating
    end
  end
end
