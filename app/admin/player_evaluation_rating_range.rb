ActiveAdmin.register PlayerEvaluationRatingRange do
  menu label: 'Ratings', parent: 'Player Evaluation', priority: 2

  permit_params :min_score, :max_score, :rating

  config.sort_order = 'rating_desc'

  action_item :update_users_skill_ratings, only: [:index] do
    link_to 'Recalculate Users Skill Ratings',
            update_users_skill_ratings_admin_player_evaluation_rating_ranges_path,
            method: :post,
            data: { confirm: 'Are you sure you want to recalculate user\'s skill ratings? ' \
                             'This will take the last user\'s player evaluation, check its ' \
                             'score, and update their skill level based on the new ranges.' }
  end

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

  collection_action :update_users_skill_ratings, method: :post do
    ActiveRecord::Base.transaction do
      user_ids = PlayerEvaluation.distinct.pluck(:user_id)

      User.where(id: user_ids).includes(:last_player_evaluation).find_each do |user|
        new_rating = user.last_player_evaluation.rating
        user.update!(skill_rating: new_rating) if user.skill_rating != new_rating
      end
    end

    flash[:notice] = 'Users skill rating successfully updated'
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to admin_player_evaluation_rating_ranges_path
  end
end
