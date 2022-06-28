require 'rails_helper'

describe 'POST api/v1/payments' do
  let!(:user) { create(:user, cc_cash: 150) }
  let!(:product) { create(:product, price: 100) }
  let(:payment_method) { create(:payment_method, user: user) }
  let(:payment_method_id) { payment_method.id }
  let(:use_cc_cash) { false }

  let(:params) do
    { product_id: product.id, payment_method_id: payment_method_id, use_cc_cash: use_cc_cash }
  end

  subject do
    post api_v1_payments_path, params: params, headers: auth_headers, as: :json
  end

  context 'when the transaction succeeds' do
    before do
      stub_request(:post, %r{stripe.com/v1/payment_intents})
        .to_return(status: 200, body: File.new('spec/fixtures/charge_succeeded.json'))
      ActiveCampaignMocker.new.mock
    end

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'creates the payment' do
      expect { subject }.to change(Payment, :count).by(1)
    end

    it "increments user's credits" do
      expect { subject }.to change { user.reload.credits }.from(0).to(product.credits)
    end

    it 'does not use user CC cash' do
      expect { subject }.not_to change { user.reload.cc_cash }
    end

    it 'calls the Active Campaign service' do
      expect { subject }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).on_queue('default')
    end

    context 'when argument use_cc_cash is true' do
      let(:use_cc_cash) { true }

      it 'uses user CC cash' do
        expect { subject }.to change { user.reload.cc_cash }.from(150).to(50)
      end
    end

    context 'when a promo_code is applied' do
      let(:params) do
        {
          product_id: product.id,
          payment_method_id: payment_method_id,
          promo_code: promo_code.code
        }
      end

      context 'when the amount is less than the product price' do
        let(:promo_code) { create(:promo_code, discount: 50, products: [product]) }
        let(:price) { promo_code.apply_discount(product.price) }
        let(:description) { "#{product.name} purchase" }

        context "when the user hasn't used the promo code yet" do
          it 'calls the stripes charge method with the correct params' do
            expect(
              StripeService
            ).to receive(:charge).with(user, payment_method.stripe_id, price, description)
            subject rescue nil
          end

          it 'creates a UserPromoCode' do
            expect { subject }.to change(UserPromoCode, :count).by(1)
          end
        end

        context 'when the user has already used the promo code' do
          let!(:user_promo_code) { create(:user_promo_code, user: user, promo_code: promo_code) }

          it 'increments the times used' do
            expect { subject }.to change { user_promo_code.reload.times_used }.from(1).to(2)
          end

          it "doesn't create a UserPromoCode" do
            expect { subject }.not_to change(UserPromoCode, :count)
          end
        end

        context 'when the the promo code has expired' do
          let!(:promo_code) { create(:promo_code, discount: 50, expiration_date: 2.days.ago) }

          it 'returns promo_code invalid error message' do
            subject
            expect(json[:error]).to eq(I18n.t('api.errors.promo_code.invalid'))
          end

          it "doesn't create a UserPromoCode" do
            expect { subject }.not_to change(UserPromoCode, :count)
          end
        end
      end
    end
  end

  context 'when the transaction fails' do
    before do
      stub_request(:post, %r{stripe.com/v1/payment_intents}).to_return(status: 400, body: '{}')
      ActiveCampaignMocker.new.mock
    end

    it "doesn't increment user's credits" do
      expect { subject }.not_to change { user.reload.credits }
    end

    it "doesn't call the Active Campaign service" do
      expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
      subject
    end
  end
end
