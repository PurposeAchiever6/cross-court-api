require 'rails_helper'

describe 'POST api/v1/purchases' do
  let!(:user)          { create(:user) }
  let!(:product)       { create(:product, price: 200) }
  let(:payment_method) { 'pm123456789' }
  let(:params)         { { product_id: product.stripe_id, payment_method: payment_method } }

  subject do
    post api_v1_purchases_path, params: params, headers: auth_headers, as: :json
  end

  context 'when the transaction succeeds' do
    before do
      stub_request(:post, %r{stripe.com/v1/payment_intents})
        .to_return(status: 200, body: File.new('spec/fixtures/charge_succeeded.json'))
      allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
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

    it 'calls the klaviyo service' do
      expect_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
      subject
    end

    context 'when a promo_code is applied' do
      let(:params) do
        {
          product_id: product.stripe_id,
          payment_method: payment_method,
          promo_code: promo_code.code
        }
      end

      context 'when the amount is less than the product price' do
        let(:promo_code) { create(:promo_code, discount: 100) }

        it 'calls the stripes charge method with the correct params' do
          expect(StripeService).to receive(:charge).with(user, payment_method, product, promo_code)
          subject
        end
      end
    end
  end

  context 'when the transaction fails' do
    before do
      stub_request(:post, %r{stripe.com/v1/payment_intents})
        .to_return(status: 400, body: '{}')
      allow_any_instance_of(KlaviyoService).to receive(:event).and_return(1)
    end

    it "doesn't create the purchase" do
      expect { subject }.not_to change(Purchase, :count)
    end

    it "doesn't increment user's credits" do
      expect { subject }.not_to change { user.reload.credits }
    end

    it "doesn't call the klaviyo service" do
      expect_any_instance_of(KlaviyoService).not_to receive(:event)
      subject
    end
  end
end
