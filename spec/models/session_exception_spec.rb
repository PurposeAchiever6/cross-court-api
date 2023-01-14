# == Schema Information
#
# Table name: session_exceptions
#
#  id         :bigint           not null, primary key
#  session_id :bigint           not null
#  date       :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_session_exceptions_on_date_and_session_id  (date,session_id)
#  index_session_exceptions_on_session_id           (session_id)
#

require 'rails_helper'

describe SessionException do
  describe 'validations' do
    subject { build(:session_exception) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:session_id) }
  end
end
