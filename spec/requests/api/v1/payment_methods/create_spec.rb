require 'rails_helper'

describe 'POST api/v1/payment_methods' do
  let(:user) { create(:user) }
  let(:params) { { payment_method: 'pm_123456789' } }

  before do
    stub_request(:post, %r{stripe.com/v1/payment_methods/*})
      .to_return(status: 200, body: '{}')
  end

  subject do
    post api_v1_payment_methods_path, params: params, headers: auth_headers, as: :json
  end

  it 'returns success' do
    subject
    expect(response).to be_successful
  end
end
