# == Schema Information
#
# Table name: user_sessions
#
#  id                          :integer          not null, primary key
#  user_id                     :integer          not null
#  session_id                  :integer          not null
#  state                       :integer          default("reserved"), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  date                        :date             not null
#  sms_reminder_sent           :boolean          default(FALSE), not null
#  email_reminder_sent         :boolean          default(FALSE), not null
#  checked_in                  :boolean          default(FALSE), not null
#  is_free_session             :boolean          default(FALSE), not null
#  free_session_payment_intent :string
#
# Indexes
#
#  index_user_sessions_on_date_user_id_state_session_id  (date,user_id,state,session_id) UNIQUE
#  index_user_sessions_on_email_reminder_sent            (email_reminder_sent)
#  index_user_sessions_on_session_id                     (session_id)
#  index_user_sessions_on_sms_reminder_sent              (sms_reminder_sent)
#  index_user_sessions_on_user_id                        (user_id)
#

require 'rails_helper'

describe UserSession do
  subject { build :user_session }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to define_enum_for(:state).with_values(%i[reserved canceled confirmed]) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(%i[session_id user_id state]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end
end
