require 'rails_helper'

describe 'POST api/v1/subscriptions' do
  let(:user)    { create(:user) }
  let(:product) { create(:product) }
  let(:params) do
    {
      payment_method: 'pm_1FjqZCEbKIwsJiGZ39uK79hz',
      stripe_product_id: product.stripe_id
    }
  end
  before do
    stub_request(:post, %r{api.stripe.com/v1/customers})
      .to_return(status: 200, body: File.new('spec/support/fixtures/create_customer_ok.json'))
    stub_request(:post, %r{api.stripe.com/v1/subscriptions})
      .to_return(status: 200, body: File.new('spec/support/fixtures/create_subscription_ok.json'))
  end

  subject do
    post api_v1_subscriptions_path, headers: auth_headers, params: params, as: :json
  end

  context 'with valid params' do
    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it "changes user's product_id" do
      expect { subject }.to change { user.reload.product_id }.from(nil).to(product.id)
    end
  end
end
