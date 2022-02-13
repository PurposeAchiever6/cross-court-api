# == Schema Information
#
# Table name: user_sessions
#
#  id                              :integer          not null, primary key
#  user_id                         :integer          not null
#  session_id                      :integer          not null
#  state                           :integer          default("reserved"), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  date                            :date             not null
#  checked_in                      :boolean          default(FALSE), not null
#  is_free_session                 :boolean          default(FALSE), not null
#  free_session_payment_intent     :string
#  credit_reimbursed               :boolean          default(FALSE), not null
#  referral_id                     :integer
#  jersey_rental                   :boolean          default(FALSE)
#  jersey_rental_payment_intent_id :string
#  assigned_team                   :string
#  no_show_up_fee_charged          :boolean          default(FALSE)
#
# Indexes
#
#  index_user_sessions_on_session_id  (session_id)
#  index_user_sessions_on_user_id     (user_id)
#

require 'rails_helper'

describe UserSession do
  subject { build :user_session }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to define_enum_for(:state).with_values(%i[reserved canceled confirmed]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end
end
