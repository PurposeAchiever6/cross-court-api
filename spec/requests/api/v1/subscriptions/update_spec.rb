require 'rails_helper'

describe 'PUT api/v1/subscriptions/:id' do
  let!(:user) { create(:user) }
  let!(:payment_method) { create(:payment_method, user:) }
  let!(:product) { create(:product, price: 100, product_type: :recurring, credits: 4) }
  let!(:new_product) { create(:product, price: 120, product_type: :recurring, credits: 8) }
  let!(:subscription) { create(:subscription, product:, user:) }
  let(:params) { { product_id: new_product.id, payment_method_id: payment_method.id } }

  subject do
    put api_v1_subscription_path(subscription), params:, headers: auth_headers, as: :json
  end

  context 'when the transaction succeeds' do
    before do
      stub_request(:post, %r{stripe.com/v1/subscriptions/stripe-subscription-id})
        .to_return(status: 200, body: File.new('spec/fixtures/subscription_succeeded.json'))
      ActiveCampaignMocker.new.mock
      allow_any_instance_of(Slack::Notifier).to receive(:ping)
    end

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'changes the product subscription' do
      expect { subject }.to change {
        user.reload.active_subscription.product
      }.from(product).to(new_product)
    end

    it 'changes the product credits' do
      expect { subject }.to change {
        user.reload.active_subscription.product.credits
      }.from(product.credits).to(new_product.credits)
    end

    it 'calls Slack Service' do
      expect_any_instance_of(SlackService).to receive(:subscription_updated)
      subject
    end
  end

  context 'when the product is the same as the subscription' do
    before { params.merge!(product_id: product.id) }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the correct error message' do
      subject
      expect(json[:error]).to eq('The subscription already has the selected product')
    end
  end

  context 'when the transaction fails' do
    let(:stripe_error_msg) { 'Stripe Error' }

    before do
      ActiveCampaignMocker.new.mock
      expect(Stripe::Subscription).to receive(:update).and_raise(
        Stripe::StripeError,
        stripe_error_msg
      )
    end

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the correct error message' do
      subject
      expect(json[:error]).to eq(stripe_error_msg)
    end

    it "doesn't change the subscription" do
      expect { subject }.not_to change { user.reload.active_subscription.product }
    end

    it "doesn't change user's subscription credits" do
      expect { subject }.not_to change { user.reload.active_subscription.product.credits }
    end

    it "doesn't call the Active Campaign service" do
      expect_any_instance_of(ActiveCampaignService).not_to receive(:create_deal)
      subject
    end

    it 'does not call Slack Service' do
      expect_any_instance_of(SlackService).not_to receive(:subscription_updated)
      subject
    end
  end
end
