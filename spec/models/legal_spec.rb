# == Schema Information
#
# Table name: legals
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  text       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_legals_on_title  (title)
#

require 'rails_helper'

describe Legal do
  describe 'validations' do
    subject { build(:legal) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title) }
    it { is_expected.to validate_presence_of(:text) }
  end
end
