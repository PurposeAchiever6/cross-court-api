# == Schema Information
#
# Table name: player_evaluation_rating_ranges
#
#  id        :bigint           not null, primary key
#  min_score :float
#  max_score :float
#  rating    :float
#

class PlayerEvaluationRatingRange < ApplicationRecord
  has_paper_trail

  validates :min_score,
            :max_score,
            :rating,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  scope :for_score, ->(score) { where('min_score <= :score AND max_score >= :score', score:) }

  def self.rating_for_score(score)
    for_score(score).first&.rating
  end
end
