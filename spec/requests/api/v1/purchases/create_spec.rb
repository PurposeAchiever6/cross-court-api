require 'rails_helper'

describe 'POST api/v1/purchases' do
  let!(:user)          { create(:user) }
  let!(:product)       { create(:product, price: 100) }
  let(:payment_method) { 'pm123456789' }
  let(:params)         { { product_id: product.id, payment_method: payment_method } }

  subject do
    post api_v1_purchases_path, params: params, headers: auth_headers, as: :json
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

    it 'creates the purchase' do
      expect { subject }.to change(Purchase, :count).by(1)
    end

    it "increments user's credits" do
      expect { subject }.to change { user.reload.credits }.from(0).to(product.credits)
    end

    it 'calls the Active Campaign service' do
      expect_any_instance_of(ActiveCampaignService).to receive(:create_deal).and_return(1)
      subject
    end

    context 'when a promo_code is applied' do
      let(:params) do
        {
          product_id: product.id,
          payment_method: payment_method,
          promo_code: promo_code.code
        }
      end

      context 'when the amount is less than the product price' do
        let(:promo_code) { create(:promo_code, discount: 50, products: [product]) }
        let(:price) { promo_code.apply_discount(product.price) }
        let(:description) { "#{product.name} purchase" }

        context "when the user hasn't used the promo code yet" do
          it 'calls the stripes charge method with the correct params' do
            expect(StripeService).to receive(:charge).with(user, payment_method, price, description)
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

    it "doesn't create the purchase" do
      expect { subject }.not_to change(Purchase, :count)
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
