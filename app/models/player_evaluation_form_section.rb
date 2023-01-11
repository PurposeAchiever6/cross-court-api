# == Schema Information
#
# Table name: player_evaluation_form_sections
#
#  id         :integer          not null, primary key
#  title      :string
#  subtitle   :string
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  required   :boolean          default(TRUE)
#
# Indexes
#
#  index_player_evaluation_form_sections_on_title  (title) UNIQUE
#

class PlayerEvaluationFormSection < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  validates :order,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  has_many :options,
           -> { order(score: :asc) },
           class_name: 'PlayerEvaluationFormSectionOption',
           inverse_of: :player_evaluation_form_section,
           dependent: nil

  accepts_nested_attributes_for :options, allow_destroy: true

  default_scope { order(order: :asc) }

  scope :required, -> { where(required: true) }

  def key
    title.parameterize
  end

  def options_formatted
    options.map { |option|
      "<div>#{option.title}\n#{option.content}\nScore: #{option.score}</div>"
    }.join("\n")
  end
end
