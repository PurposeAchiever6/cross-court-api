require 'rails_helper'

describe 'DELETE api/v1/payment_methods' do
  let(:user) { create(:user) }
  let!(:payment_method) { create(:payment_method, user: user, default: true) }
  let!(:payment_method_2) { create(:payment_method, user: user) }
  let!(:payment_method_3) { create(:payment_method, user: user) }
  let!(:payment_method_4) { create(:payment_method, user: user) }

  let(:payment_method_atts) { { stripe_id: payment_method.stripe_id } }

  before { StripeMocker.new.detach_payment_method(user.stripe_id, payment_method_atts) }

  subject do
    delete api_v1_payment_method_path(payment_method.id),
           headers: auth_headers,
           as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it { expect { subject }.to change(PaymentMethod, :count).by(-1) }

  it 'returns the remaining user payments methods' do
    subject
    expect(json[:payment_methods].count).to eq(3)
  end

  it 'assign default to the next most recent one' do
    subject
    expect(user.payment_methods.reload.order(created_at: :desc).first.default).to eq(true)
  end

  context 'when payment method is not found' do
    let!(:other_user) { create(:user) }
    let!(:payment_method) { create(:payment_method, user: other_user) }
    let(:payment_method_atts) { { stripe_id: payment_method.stripe_id } }

    it 'returns not_found' do
      subject
      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when payment method has an active subscription' do
    let!(:subscription) { create(:subscription, user: user, payment_method: payment_method) }

    it 'returns bad_request' do
      subject
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns the correct error message' do
      subject
      expect(json[:error]).to eq('The payment method has an active membership')
    end
  end
end
