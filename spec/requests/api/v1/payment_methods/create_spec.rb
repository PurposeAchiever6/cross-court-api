require 'rails_helper'

describe 'POST api/v1/payment_methods' do
  let(:user) { create(:user) }
  let(:payment_method_stripe_id) { 'pm_123456789' }
  let(:params) { { payment_method_stripe_id: payment_method_stripe_id } }
  let(:payment_method_atts) { { stripe_id: payment_method_stripe_id } }

  let!(:user) { create(:user) }

  before { StripeMocker.new.attach_payment_method(user.stripe_id, payment_method_atts) }

  subject do
    post api_v1_payment_methods_path, params: params, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end
end
