# == Schema Information
#
# Table name: session_survey_questions
#
#  id           :bigint           not null, primary key
#  question     :string           not null
#  is_enabled   :boolean          default(TRUE)
#  is_mandatory :boolean          default(FALSE)
#  type         :integer
#
# Indexes
#
#  index_session_survey_questions_on_type  (type)
#

class SessionSurveyQuestion < ApplicationRecord
  self.inheritance_column = :_type_disabled

  has_many :session_survey_answers, dependent: :nullify

  enum type: { rate: 0, open: 1 }, _suffix: true

  validates :question, presence: true

  scope :enabled, -> { where(is_enabled: true) }
  scope :mandatory, -> { where(is_mandatory: true) }

  def display_name
    question
  end
end
