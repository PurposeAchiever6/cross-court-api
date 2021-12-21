require 'rails_helper'

describe 'POST api/v1/subscriptions' do
  let!(:user)          { create(:user) }
  let!(:product)       { create(:product, price: 100, product_type: :recurring) }
  let(:payment_method) { 'pm123456789' }
  let(:params)         { { product_id: product.id, payment_method: payment_method } }

  subject do
    post api_v1_subscriptions_path, params: params, headers: auth_headers, as: :json
  end

  context 'when the transaction succeeds' do
    before do
      stub_request(:post, %r{stripe.com/v1/subscriptions})
        .to_return(status: 200, body: File.new('spec/fixtures/subscription_succeeded.json'))
      ActiveCampaignMocker.new.mock
    end

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'creates the subscription' do
      expect { subject }.to change(Subscription, :count).by(1)
    end

    it 'creates the purchase' do
      expect { subject }.to change(Purchase, :count).by(1)
    end

    it "increments user's subscription credits" do
      expect { subject }.to change { user.reload.subscription_credits }.from(0).to(product.credits)
    end

    it 'calls the Active Campaign service' do
      expect { subject }.to have_enqueued_job(CreateActiveCampaignDealJob).on_queue('default')
    end
  end

  context 'when the transaction fails' do
    before do
      stub_request(:post, %r{stripe.com/v1/subscriptions})
        .to_return(status: 400, body: '{}')
      ActiveCampaignMocker.new.mock
    end

    it "doesn't create the subscription" do
      expect { subject }.not_to change(Subscription, :count)
    end

    it "doesn't increment user's subscription credits" do
      expect { subject }.not_to change { user.reload.subscription_credits }
    end

    it "doesn't call the Active Campaign service" do
      expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
      subject
    end
  end
end
