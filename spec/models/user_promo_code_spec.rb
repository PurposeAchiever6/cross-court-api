# == Schema Information
#
# Table name: user_promo_codes
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  promo_code_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  times_used    :integer          default(0)
#
# Indexes
#
#  index_user_promo_codes_on_promo_code_id              (promo_code_id)
#  index_user_promo_codes_on_promo_code_id_and_user_id  (promo_code_id,user_id) UNIQUE
#  index_user_promo_codes_on_user_id                    (user_id)
#

require 'rails_helper'

describe UserPromoCode do
  subject { create(:user_promo_code, user:, promo_code:) }

  let(:user) { create(:user) }
  let(:promo_code) { create(:promo_code) }

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:promo_code_id).scoped_to(:user_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:promo_code) }
  end

  context 'when already exists a record' do
    before { create(:user_promo_code, promo_code:, user:) }
    it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
  end
end
