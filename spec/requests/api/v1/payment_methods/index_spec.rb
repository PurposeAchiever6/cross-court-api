require 'rails_helper'

describe 'GET api/v1/payment_methods' do
  let(:user) { create(:user) }
  let!(:payment_method) { create(:payment_method, user: user) }

  subject do
    get api_v1_payment_methods_path, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end

  it 'returns user payments methods' do
    subject
    expect(json[:payment_methods].count).to eq(1)
  end
end
