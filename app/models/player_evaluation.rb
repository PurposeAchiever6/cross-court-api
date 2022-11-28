# == Schema Information
#
# Table name: player_evaluations
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  evaluation  :json             default({})
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

  def validate_evaluation_presence
    error = EVALUATION_REQUIRED_KEYS.any? { |key| evaluation[key].blank? }
    errors.add(:evaluation, 'options must be selected') if error
  end
end
