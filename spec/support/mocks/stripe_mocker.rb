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

  def upcoming_invoice(
    customer_id,
    subscription_id = nil,
    items = nil,
    proration_date = nil,
    _promo_code = nil
  )
    mock_request(
      url_path: '/invoices/upcoming',
      method: :get,
      response_body: invoice_response(customer_id, subscription_id),
      query: {
        subscription_items: items,
        customer: customer_id,
        subscription: subscription_id,
        subscription_proration_date: proration_date
      }
    )
  end

  private

  def mock_request(
    url_path:,
    method:,
    request_body: nil,
    query: nil,
    response_body: {}.to_json,
    status: 200
  )
    WebMock.stub_request(method, "#{base_url}#{url_path}").with(
      query: query,
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

  def invoice_response(customer_id, subscription_id)
    {
      currency: 'usd',
      customer: customer_id || 'cus_AJ6y81jMo1Na22',
      lines: {
        object: 'list',
        data: [
          {
            id: 'il_1Kooo9EbKIwsJiGZ9Ip7Efqr',
            object: 'line_item',
            amount: 1239,
            currency: 'usd',
            description: 'Invoice Item',
            invoice_item: 'ii_1Kooo9EbKIwsJiGZCMMpX356',
            price: {
              id: 'price_1KmnWrEbKIwsJiGZoVZMWIIJ',
              object: 'price',
              active: true,
              billing_scheme: 'per_unit',
              created: 1_649_546_237,
              currency: 'usd',
              product: 'prod_LTl2QHNJinvoVV'
            }
          }
        ]
      },
      period_end: 1_650_027_809,
      period_start: 1_650_027_809,
      subscription: subscription_id,
      subtotal: 1239,
      tax: nil,
      tax_percent: nil,
      total: 1239
    }.to_json
  end
end
