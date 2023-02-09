require 'rails_helper'

describe Subscriptions::ApplyCcCash do
  describe '.call' do
    let(:price) { rand(50..80) }
    let(:product) { create(:product, price:) }
    let(:status) { :active }
    let(:promo_code) { nil }
    let(:subscription) { create(:subscription, product:, status:, promo_code:) }
    let(:cc_cash) { rand(100..200) }
    let(:apply_cc_cash_to_subscription) { true }
    let(:user) do
      create(
        :user,
        active_subscription: subscription,
        cc_cash:,
        apply_cc_cash_to_subscription:
      )
    end
    let(:stripe_discount) { nil }

    before do
      stripe_mocker = StripeMocker.new
      stripe_mocker.retrieve_subscription(subscription.stripe_id, stripe_discount)
      stripe_mocker.update_subscription(subscription.stripe_id, 'coupon-id')
    end

    subject { Subscriptions::ApplyCcCash.call(user:, subscription:) }

    it 'does updates user cc_cash' do
      expect { subject }.to change { user.reload.cc_cash }.from(cc_cash).to(cc_cash - product.price)
    end

    it { expect { subject }.to change(PromoCode, :count).by(1) }

    it 'assigns the promo code to the subscription' do
      subject
      promo_code = PromoCode.last

      expect(promo_code.use).to eq('cc_cash')
      expect(subscription.reload.promo_code.id).to eq(promo_code.id)
    end

    context 'when the user has the setting disabled' do
      let(:apply_cc_cash_to_subscription) { false }

      it { expect { subject }.not_to change { user.reload.cc_cash } }

      it { expect { subject }.not_to change(PromoCode, :count) }
    end

    context 'when the subscription is not active' do
      let(:status) { :paused }

      it { expect { subject }.not_to change { user.reload.cc_cash } }

      it { expect { subject }.not_to change(PromoCode, :count) }
    end

    context 'when the user does not have cc_cash' do
      let(:cc_cash) { 0 }

      it { expect { subject }.not_to change { user.reload.cc_cash } }

      it { expect { subject }.not_to change(PromoCode, :count) }
    end

    context 'when the user already has a discount and is not cc_cash' do
      let(:promo_code) { create(:promo_code, use: 'general') }
      let(:stripe_discount) do
        {
          discount: {
            id: 'di_1MZhEpEbKIwsJiGZ3mEwO2LZ',
            coupon: {
              id: 'ztMkNJb9',
              object: 'coupon',
              amount_off: 7200,
              created: 1_675_976_462,
              currency: 'usd',
              duration: 'once',
              duration_in_months: nil,
              livemode: false,
              max_redemptions: nil,
              metadata: {},
              name: nil,
              percent_off: nil,
              redeem_by: nil,
              times_redeemed: 1,
              valid: true
            },
            customer: 'cus_LstpzbCvjje1wf',
            end: nil,
            invoice: nil,
            invoice_item: nil,
            promotion_code: nil,
            start: 1_675_976_462,
            subscription: subscription.stripe_id
          }
        }
      end

      it { expect { subject }.not_to change { user.reload.cc_cash } }

      it { expect { subject }.not_to change(PromoCode, :count) }

      it { expect { subject }.not_to change { subscription.reload.promo_code } }
    end
  end
end
