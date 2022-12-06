class CreatePlayerEvaluationRatingRanges < ActiveRecord::Migration[6.0]
  def change
    create_table :player_evaluation_rating_ranges do |t|
      t.float :min_score
      t.float :max_score
      t.float :rating
    end
  end
end
