# == Schema Information
#
# Table name: products
#
#  id              :integer          not null, primary key
#  credits         :integer          default(0), not null
#  name            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  price           :decimal(10, 2)   default(0.0), not null
#  order_number    :integer          default(0), not null
#  product_type    :integer          default("one_time")
#  stripe_price_id :string
#  label           :string
#  deleted_at      :datetime
#
# Indexes
#
#  index_products_on_deleted_at  (deleted_at)
#

require 'rails_helper'

describe Product do
  describe 'validations' do
    subject { build(:product) }

    it { is_expected.to validate_presence_of(:credits) }
  end
end
