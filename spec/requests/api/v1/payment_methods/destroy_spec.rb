require 'rails_helper'

describe 'DELETE api/v1/payment_methods' do
  let(:user)           { create(:user) }
  let(:payment_method) { 'pm_123456789' }

  before do
    stub_request(:post, %r{stripe.com/v1/payment_methods/pm_123456789/detach})
      .to_return(status: 200, body: '{}')
  end

  subject do
    delete api_v1_payment_method_path(payment_method),
           headers: auth_headers,
           as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end
end
