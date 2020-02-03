# == Schema Information
#
# Table name: purchases
#
#  id         :integer          not null, primary key
#  product_id :integer
#  user_id    :integer
#  price      :decimal(10, 2)   not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  credits    :integer          not null
#  name       :string           not null
#
# Indexes
#
#  index_purchases_on_product_id  (product_id)
#  index_purchases_on_user_id     (user_id)
#

require 'rails_helper'

describe Purchase do
  describe 'validations' do
    subject { build(:purchase) }

    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_presence_of(:credits) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end
end
