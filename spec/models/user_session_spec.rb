# == Schema Information
#
# Table name: user_sessions
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  session_id :integer          not null
#  state      :integer          default("reserved"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_sessions_on_session_id              (session_id)
#  index_user_sessions_on_user_id                 (user_id)
#  index_user_sessions_on_user_id_and_session_id  (user_id,session_id) UNIQUE
#

require 'rails_helper'

describe UserSession do
  subject { build :user_session }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to define_enum_for(:state).with_values([:reserved]) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:session_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:session) }
  end
end
