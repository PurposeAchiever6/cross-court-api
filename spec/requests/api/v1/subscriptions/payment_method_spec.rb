require 'rails_helper'

describe 'POST api/v1/subscriptions/:id/payment_method' do
  let!(:user) { create(:user) }
  let!(:payment_method) { create(:payment_method, user: user) }
  let!(:subscription) { create(:subscription, user: user, status: subscription_status) }
  let!(:old_payment_method) { subscription.payment_method }

  let(:subscription_id) { subscription.id }
  let(:payment_method_id) { payment_method.id }
  let(:subscription_status) { 'active' }
  let(:request_headers) { auth_headers }
  let(:params) { { payment_method_id: payment_method_id } }

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  before { allow(Stripe::Subscription).to receive(:update) }

  subject do
    post payment_method_api_v1_subscription_path(subscription_id),
         headers: request_headers,
         params: params,
         as: :json
    response
  end

  it { is_expected.to be_successful }

  it 'changes subscription payment method' do
    expect { subject }.to change {
      subscription.reload.payment_method
    }.from(old_payment_method).to(payment_method)
  end

  it { expect(response_body[:id]).to eq(subscription.id) }

  context 'when user is not logged in' do
    let(:request_headers) { nil }

    it { is_expected.to be_unauthorized }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end

  context 'when the subscription is not active' do
    let(:subscription_status) { 'canceled' }

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq('The subscription is not active') }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end

  context 'when the subscription does not exist' do
    let(:subscription_id) { -1 }

    it { is_expected.to have_http_status(:not_found) }
    it { expect(response_body[:error]).to eq('Couldn\'t find the record') }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end

  context 'when the subscription is for another user' do
    let!(:another_user) { create(:user) }
    let!(:subscription) { create(:subscription, user: another_user, status: subscription_status) }

    it { is_expected.to have_http_status(:not_found) }
    it { expect(response_body[:error]).to eq('Couldn\'t find the record') }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end

  context 'when the payment method does not exist' do
    let(:payment_method_id) { -1 }

    it { is_expected.to have_http_status(:not_found) }
    it { expect(response_body[:error]).to eq('Couldn\'t find the record') }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end

  context 'when the payment method is for another user' do
    let!(:another_user) { create(:user) }
    let!(:payment_method) { create(:payment_method, user: another_user) }

    it { is_expected.to have_http_status(:not_found) }
    it { expect(response_body[:error]).to eq('Couldn\'t find the record') }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end

  context 'when stripe fails' do
    let(:stripe_error_msg) { 'Stripe error message' }

    before do
      allow(
        Stripe::Subscription
      ).to receive(:update).and_raise(Stripe::StripeError, stripe_error_msg)
    end

    it { is_expected.to have_http_status(:bad_request) }
    it { expect(response_body[:error]).to eq(stripe_error_msg) }
    it { expect { subject }.not_to change { subscription.reload.payment_method } }
  end
end
