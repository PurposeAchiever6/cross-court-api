# == Schema Information
#
# Table name: session_survey_answers
#
#  id                         :integer          not null, primary key
#  answer                     :string
#  session_survey_question_id :integer
#  user_session_id            :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#
# Indexes
#
#  index_session_survey_answers_on_session_survey_question_id  (session_survey_question_id)
#  index_session_survey_answers_on_user_session_id             (user_session_id)
#

class SessionSurveyAnswer < ApplicationRecord
  belongs_to :session_survey_question
  belongs_to :user_session

  has_one :user, through: :user_session

  validates :answer, presence: true, if: -> { session_survey_question&.is_mandatory? }
end
