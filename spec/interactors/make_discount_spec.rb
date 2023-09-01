require 'rails_helper'

describe MakeDiscount do
  describe '.call' do
    let!(:user) { create(:user) }
    let!(:product) { create(:product, product_type: 'recurring') }
    let(:product_price) { product.price(user).to_i }
    let!(:promo_code) { create(:promo_code, use: 'general', products: [product]) }

    subject do
      described_class.call(
        user:,
        promo_code:,
        product:
      )
    end

    it { expect(subject.amount).to eq(promo_code.apply_discount(product_price)) }
    it { expect(subject.discount).to eq(promo_code.discount_amount(product_price)) }

    context 'when the promo code is not present' do
      let(:promo_code) { nil }

      it { expect(subject.amount).to eq(product_price) }
      it { expect(subject.discount).to eq(0) }
    end
  end
end
