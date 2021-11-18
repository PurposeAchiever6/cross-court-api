# == Schema Information
#
# Table name: session_survey_questions
#
#  id           :integer          not null, primary key
#  question     :string           not null
#  is_enabled   :boolean          default(TRUE)
#  is_mandatory :boolean          default(FALSE)
#  type         :integer
#
# Indexes
#
#  index_session_survey_questions_on_type  (type)
#

require 'rails_helper'

describe SessionSurveyQuestion do
  describe 'validations' do
    subject { build(:session_survey_question) }

    it { is_expected.to validate_presence_of(:question) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:session_survey_answers) }
  end
end
