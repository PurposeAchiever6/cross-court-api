# == Schema Information
#
# Table name: products
#
#  id           :integer          not null, primary key
#  stripe_id    :string           not null
#  credits      :integer          default(0), not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  price        :decimal(10, 2)   default(0.0), not null
#  description  :text
#  order_number :integer          default(0), not null
#
# Indexes
#
#  index_products_on_stripe_id  (stripe_id)
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
