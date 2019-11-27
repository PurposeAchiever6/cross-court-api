# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  stripe_id      :string           not null
#  credits        :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string           default(""), not null
#  stripe_plan_id :string
#
# Indexes
#
#  index_products_on_stripe_id  (stripe_id) UNIQUE
#

require 'rails_helper'

describe Product do
  describe 'validations' do
    subject { build(:product) }

    it { is_expected.to validate_presence_of(:stripe_id) }
    it { is_expected.to validate_presence_of(:credits) }
    it { is_expected.to validate_uniqueness_of(:stripe_id) }
    it { is_expected.to validate_numericality_of(:credits).is_greater_than_or_equal_to(0) }
  end
end
