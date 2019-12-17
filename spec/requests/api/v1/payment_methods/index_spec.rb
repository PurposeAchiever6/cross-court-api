require 'rails_helper'

describe 'GET api/v1/payment_methods' do
  let(:user) { create(:user) }

  before do
    stub_request(:get, %r{stripe.com/v1/payment_methods})
      .to_return(status: 200, body: File.new('spec/fixtures/payment_methods.json'))
  end

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
