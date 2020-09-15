# == Schema Information
#
# Table name: session_survey_questions
#
#  id           :integer          not null, primary key
#  question     :string           not null
#  is_enabled   :boolean          default(TRUE)
#  is_mandatory :boolean          default(FALSE)
#

class SessionSurveyQuestion < ApplicationRecord
  validates :question, presence: true

  has_many :session_survey_answers, dependent: :nullify

  scope :enabled, -> { where(is_enabled: true) }
  scope :mandatory, -> { where(is_mandatory: true) }
end
