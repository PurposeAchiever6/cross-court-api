# == Schema Information
#
# Table name: player_evaluation_form_section_options
#
#  id                                :bigint           not null, primary key
#  title                             :string
#  content                           :string
#  score                             :float
#  player_evaluation_form_section_id :bigint
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
# Indexes
#
#  index_on_player_evaluation_form_section_id  (player_evaluation_form_section_id)
#

class PlayerEvaluationFormSectionOption < ApplicationRecord
  has_paper_trail

  validates :content, presence: true
  validates :score,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  belongs_to :player_evaluation_form_section,
             touch: true,
             inverse_of: :options
end
