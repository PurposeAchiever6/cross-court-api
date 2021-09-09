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
  subject { build(:user_promo_code) }
  let(:user) { create(:user) }
  let(:promo_code) { create(:promo_code, product: product) }

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:promo_code_id).scoped_to(:user_id) }
  end

  describe 'associations' do
    before { allow(subject).to receive(:one_time_product?).and_return(true) }

    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:promo_code) }
  end

  context 'when product is one_time' do
    let(:product) { create(:product, product_type: 'one_time') }

    before { create(:user_promo_code, promo_code: promo_code, user: user) }

    subject { create(:user_promo_code, promo_code: promo_code, user: user) }

    it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
  end

  context 'when product is recurring' do
    let(:product) { create(:product, product_type: 'recurring') }

    before { create(:user_promo_code, promo_code: promo_code, user: user) }

    subject { create(:user_promo_code, promo_code: promo_code, user: user) }

    it { expect { subject }.not_to raise_error }
    it { expect { subject }.to change(UserPromoCode, :count) }
  end
end
