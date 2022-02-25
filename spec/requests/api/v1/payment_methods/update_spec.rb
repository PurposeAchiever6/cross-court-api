require 'rails_helper'

describe 'PUT api/v1/payment_methods/:id' do
  let(:user) { create(:user) }
  let!(:payment_method) { create(:payment_method, user: user, default: false) }
  let!(:payment_method_2) { create(:payment_method, user: user, default: true) }
  let(:params) { { payment_method: { default: true } } }

  subject do
    put api_v1_payment_method_path(payment_method.id),
        params: params, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject

    expect(response).to be_successful
  end

  it 'updates the payment_method default attribute and removes the previous default' do
    subject

    expect(payment_method.reload.default).to eq(true)
    expect(payment_method_2.reload.default).to eq(false)
  end

  it 'returns user payments methods' do
    subject
    expect(json[:payment_methods].count).to eq(2)
  end
end
