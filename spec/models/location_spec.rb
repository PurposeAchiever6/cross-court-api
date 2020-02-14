# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  direction  :string           not null
#  lat        :float            not null
#  lng        :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city       :string           default(""), not null
#  zipcode    :string           default(""), not null
#  time_zone  :string           default("America/Los_Angeles"), not null
#  deleted_at :datetime
#
# Indexes
#
#  index_locations_on_deleted_at  (deleted_at)
#

require 'rails_helper'

describe Location do
  describe 'validations' do
    subject { build :location }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_presence_of(:lat) }
    it { is_expected.to validate_presence_of(:lng) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:zipcode) }
  end
end
