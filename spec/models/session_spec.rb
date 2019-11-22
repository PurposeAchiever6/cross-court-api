# == Schema Information
#
# Table name: sessions
#
#  id          :integer          not null, primary key
#  start_time  :date             not null
#  recurring   :text
#  time        :time             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer          not null
#
# Indexes
#
#  index_sessions_on_location_id  (location_id)
#

require 'rails_helper'

describe Session do
  describe 'validations' do
    subject { build :session }
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:time) }
    it { is_expected.to belong_to(:location) }
  end
end
