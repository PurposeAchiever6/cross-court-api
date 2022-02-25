# frozen_string_literal: true

class StripeMocker
  attr_reader :base_url

  def initialize
    @base_url = 'https://api.stripe.com/v1'
  end

  def attach_payment_method(customer_id, payment_method_attrs = {})
    mock_request(
      url_path: "/payment_methods/#{payment_method_attrs[:stripe_id]}/attach",
      request_body: { customer: customer_id },
      method: :post,
      response_body: payment_method_response(customer_id, payment_method_attrs)
    )
  end

  def detach_payment_method(customer_id, payment_method_attrs = {})
    mock_request(
      url_path: "/payment_methods/#{payment_method_attrs[:stripe_id]}/detach",
      method: :post,
      response_body: payment_method_response(customer_id, payment_method_attrs)
    )
  end

  private

  def mock_request(
    url_path:,
    method:,
    request_body: nil,
    response_body: {}.to_json,
    status: 200
  )
    WebMock.stub_request(method, "#{base_url}#{url_path}").with(
      body: request_body
    ).to_return(
      status: status,
      body: response_body,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def payment_method_response(customer_id, payment_method_attrs)
    {
      id: payment_method_attrs[:stripe_id] || 'pm_1KNPtU2eZvKYlo2CU8lSLtkE',
      card: {
        brand: payment_method_attrs[:brand] || 'visa',
        exp_month: payment_method_attrs[:exp_month] || 9,
        exp_year: payment_method_attrs[:exp_year] || 2100,
        last4: payment_method_attrs[:last_4] || '4242'
      },
      customer: customer_id || 'cus_AJ6y81jMo1Na22',
      type: 'card'
    }.to_json
  end
end
