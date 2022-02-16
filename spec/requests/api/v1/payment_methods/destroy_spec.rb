require 'rails_helper'

describe 'DELETE api/v1/payment_methods' do
  let(:user) { create(:user) }
  let(:payment_method) { create(:payment_method, user: user) }

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
end
