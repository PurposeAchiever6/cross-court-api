require 'rails_helper'

describe 'POST api/v1/subscriptions' do
  let!(:user) { create(:user, reserve_team: reserve_team) }
  let(:reserve_team) { false }
  let!(:payment_method) { create(:payment_method, user: user) }
  let!(:product) do
    create(:product, price: 100, product_type: :recurring, available_for: available_for)
  end
  let(:available_for) { :everyone }
  let(:params) { { product_id: product.id, payment_method_id: payment_method.id } }

  subject do
    post api_v1_subscriptions_path, params: params, headers: auth_headers, as: :json
  end

  context 'when the transaction succeeds' do
    before do
      stub_request(:post, %r{stripe.com/v1/subscriptions})
        .to_return(status: 200, body: File.new('spec/fixtures/subscription_succeeded.json'))
      StripeMocker.new.retrieve_invoice(user.stripe_id, 'in_1Fin1BEbKIwsJiGZiMSDSLzw')
      ActiveCampaignMocker.new.mock
    end

    it 'returns success' do
      subject
      expect(response).to be_successful
    end

    it 'creates the subscription' do
      expect { subject }.to change(Subscription, :count).by(1)
    end

    it 'creates the payment' do
      expect { subject }.to change(Payment, :count).by(1)
    end

    it "increments user's subscription credits" do
      expect { subject }.to change { user.reload.subscription_credits }.from(0).to(product.credits)
    end

    it 'calls the Active Campaign service' do
      expect {
        subject
      }.to have_enqueued_job(::ActiveCampaign::CreateDealJob).exactly(:twice).on_queue('default')
    end
  end

  context 'when user already has an active subscription' do
    let!(:active_subscription) { create(:subscription, user: user, product: product) }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the expected error message' do
      subject
      expect(json[:error]).to eq('User already has an active subscription')
    end
  end

  context 'when the user is not Reserve Team and the subscription is' do
    let!(:available_for) { :reserve_team }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the expected error message' do
      subject
      expect(json[:error]).to eq(
        'User is not part of the Reserve Team or Subscription ' \
        'is only available for Reserve Team members'
      )
    end
  end

  context 'when the user is Reserve Team and the subscription is not' do
    let(:reserve_team) { true }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the expected error message' do
      subject
      expect(json[:error]).to eq(
        'User is not part of the Reserve Team or Subscription ' \
        'is only available for Reserve Team members'
      )
    end
  end

  context 'when the transaction fails' do
    let(:stripe_error_msg) { 'Some error message' }

    before do
      ActiveCampaignMocker.new.mock
      allow(
        StripeService
      ).to receive(:create_subscription).and_raise(Stripe::StripeError, stripe_error_msg)
    end

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the expected error message' do
      subject
      expect(json[:error]).to eq(stripe_error_msg)
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
