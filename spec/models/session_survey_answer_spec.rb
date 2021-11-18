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

require 'rails_helper'

describe SessionSurveyAnswer do
  describe 'validations' do
    subject { build(:session_survey_question) }

    it { is_expected.to validate_presence_of(:question) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:session_survey_question) }
    it { is_expected.to belong_to(:user_session) }
    it { is_expected.to have_one(:user) }
  end
end
