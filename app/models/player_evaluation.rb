# == Schema Information
#
# Table name: player_evaluations
#
#  id          :bigint           not null, primary key
#  user_id     :bigint
#  evaluation  :json
#  total_score :float
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_player_evaluations_on_user_id  (user_id)
#

class PlayerEvaluation < ApplicationRecord
  EVALUATION_REQUIRED_KEYS = %w[ball-handling passing movement game-awareness shooting].freeze

  belongs_to :user

  validates :date, presence: true
  validate :validate_evaluation_presence

  before_save :calculate_total_score
  after_save :assign_user_skill_rating

  def rating
    PlayerEvaluationRatingRange.rating_for_score(total_score)
  end

  def evaluation_formatted
    evaluation.map { |key, value| "#{key.humanize}: #{value}" }.join("\n")
  end

  private

  def calculate_total_score
    total_score = evaluation.inject(0) do |total_score_acc, (_, score)|
      total_score_acc + score.to_i
    end

    self.total_score = total_score
  end

  def assign_user_skill_rating
    user.update!(skill_rating: rating)
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    raise ActiveRecord::RecordInvalid, self
  end

  def validate_evaluation_presence
    required_keys = PlayerEvaluationFormSection.required.map(&:key)
    error = required_keys.any? { |key| evaluation[key].blank? }
    errors.add(:evaluation, 'required options must be selected') if error
  end
end
