require 'rails_helper'

describe Subscriptions::ProratePrice do
  describe '.call' do
    let(:user) { create(:user) }
    let(:product) { create(:product, credits: 4, product_type: 'recurring') }
    let(:new_product) { create(:product, :unlimited, stripe_price_id: 100) }
    let(:promo_code) { create(:promo_code) }
    let!(:active_subscription) do
      create(
        :subscription,
        user:,
        product:
      )
    end
    let(:items) do
      [{
        id: active_subscription.stripe_item_id,
        price: new_product.stripe_price_id
      }]
    end
    let(:proration_date) { Time.now.to_i }

    before do
      Timecop.freeze(Time.current)
      StripeMocker.new.upcoming_invoice(
        user.stripe_id,
        active_subscription.stripe_id,
        items,
        proration_date,
        promo_code
      )
    end

    after { Timecop.return }

    subject do
      Subscriptions::ProratePrice.call(
        user:,
        new_product:,
        promo_code:
      )
    end

    it do
      expect(subject.invoice.to_json).to include_json(
        customer: user.stripe_id,
        lines: {
          data: [{
            object: 'line_item',
            amount: 1239,
            currency: 'usd',
            description: 'Invoice Item'
          }]
        },
        subscription: active_subscription.stripe_id,
        subtotal: 1239,
        total: 1239
      )
    end

    it 'calls the stripes upcoming_invoice method with the correct params' do
      expect(StripeService).to receive(
        :upcoming_invoice
      ).with(
        user.stripe_id,
        active_subscription.stripe_id,
        items,
        proration_date,
        promo_code
      )

      subject
    end
  end
end
