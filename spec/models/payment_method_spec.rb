# == Schema Information
#
# Table name: payment_methods
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  stripe_id  :string
#  brand      :string
#  exp_month  :integer
#  exp_year   :integer
#  last_4     :string
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_payment_methods_on_user_id  (user_id)
#

require 'rails_helper'

describe PaymentMethod do
  describe 'validations' do
    subject { build(:payment_method) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:stripe_id) }
    it { is_expected.to validate_uniqueness_of(:default).scoped_to(:user_id) }
  end
end