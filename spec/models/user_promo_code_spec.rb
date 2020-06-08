# == Schema Information
#
# Table name: user_promo_codes
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  promo_code_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_user_promo_codes_on_promo_code_id  (promo_code_id)
#  index_user_promo_codes_on_user_id        (user_id)
#

require 'rails_helper'

describe UserPromoCode do
  subject { build :user_promo_code }

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:promo_code_id).scoped_to(:user_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:promo_code) }
  end
end
