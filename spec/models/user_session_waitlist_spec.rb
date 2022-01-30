# == Schema Information
#
# Table name: user_session_waitlists
#
#  id         :integer          not null, primary key
#  date       :date
#  reached    :boolean          default(FALSE)
#  user_id    :integer
#  session_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_session_waitlists_on_date_and_session_id_and_user_id  (date,session_id,user_id) UNIQUE
#  index_user_session_waitlists_on_session_id                       (session_id)
#  index_user_session_waitlists_on_user_id                          (user_id)
#

require 'rails_helper'

describe UserSessionWaitlist do
  subject { build :user_session_waitlist }

  context 'validations' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(%i[session_id user_id]) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end
end
