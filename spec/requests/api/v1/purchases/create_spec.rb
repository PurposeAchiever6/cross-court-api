require 'rails_helper'

describe 'POST api/v1/purchases' do
  let!(:user)    { create(:user) }
  let!(:product) { create(:product) }
  let(:params)   { { product_id: product.stripe_id, payment_method: 'pm123456789' } }

  subject do
    post api_v1_purchases_path, params: params, headers: auth_headers, as: :json
  end

  context 'when the transaction succeeds' do
    before do
      stub_request(:post, %r{stripe.com/v1/payment_intents})
        .to_return(status: 200, body: File.new('spec/fixtures/charge_succeeded.json'))
      allow_any_instance_of(KlaviyoService).to receive(:purchase_placed).and_return(1)
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
      expect_any_instance_of(KlaviyoService).to receive(:purchase_placed).and_return(1)
      subject
    end
  end
end
