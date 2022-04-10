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

  def cancel_subscription(stripe_subscription_id)
    mock_request(
      url_path: "/subscriptions/#{stripe_subscription_id}",
      method: :delete,
      response_body: subscription_response(stripe_subscription_id)
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

  def subscription_response(stripe_subscription_id)
    {
      id: stripe_subscription_id,
      items: { data: [id: 'stripe-subscription-item-id'] },
      status: 'canceled',
      current_period_start: (Time.current - 2.weeks).to_i,
      current_period_end: (Time.current + 2.weeks).to_i,
      cancel_at: nil,
      canceled_at: Time.current.to_i,
      cancel_at_period_end: false
    }.to_json
  end
end
