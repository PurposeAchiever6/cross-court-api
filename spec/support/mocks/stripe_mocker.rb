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
      response_body: subscription_response(id: stripe_subscription_id, status: 'canceled')
    )
  end

  def pause_subscription(stripe_subscription_id, resumes_at = nil)
    mock_request(
      url_path: "/subscriptions/#{stripe_subscription_id}",
      request_body: {
        pause_collection: {
          behavior: 'mark_uncollectible',
          resumes_at:
        }
      },
      method: :post,
      response_body: subscription_response(id: stripe_subscription_id, pause_collection: true)
    )
  end

  def retrieve_subscription(stripe_subscription_id, discount = nil)
    mock_request(
      url_path: "/subscriptions/#{stripe_subscription_id}",
      method: :get,
      response_body: subscription_response(id: stripe_subscription_id, discount:)
    )
  end

  def update_subscription(stripe_subscription_id, coupon_id = nil)
    mock_request(
      url_path: "/subscriptions/#{stripe_subscription_id}",
      request_body: {
        coupon: coupon_id
      },
      method: :post,
      response_body: subscription_response(id: stripe_subscription_id)
    )
  end

  def unpause_subscription(stripe_subscription_id)
    mock_request(
      url_path: "/subscriptions/#{stripe_subscription_id}",
      request_body: {
        pause_collection: '',
        billing_cycle_anchor: 'now',
        proration_behavior: 'none',
        payment_behavior: 'error_if_incomplete'
      },
      method: :post,
      response_body: subscription_response(id: stripe_subscription_id)
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
      response_body: invoice_response(
        customer_id:,
        subscription_id:
      ),
      query: {
        subscription_items: items,
        customer: customer_id,
        subscription: subscription_id,
        subscription_proration_date: proration_date,
        subscription_billing_cycle_anchor: 'now'
      }
    )
  end

  def retrieve_invoice(customer_id, stripe_invoice_id = 'il_1Kooo9EbKIwsJiGZ9Ip7Efqr')
    mock_request(
      url_path: "/invoices/#{stripe_invoice_id}",
      method: :get,
      response_body: invoice_response(
        customer_id:,
        stripe_invoice_id:
      )
    )
  end

  def delete_customer(customer_id)
    mock_request(url_path: "/customers/#{customer_id}", method: :delete)
  end

  def delete_coupon(coupon_id)
    mock_request(url_path: "/coupons/#{coupon_id}", method: :delete)
  end

  def cancel_subscription_at_period_end(stripe_subscription_id)
    mock_request(
      url_path: "/subscriptions/#{stripe_subscription_id}",
      method: :post,
      request_body: { cancel_at_period_end: true },
      response_body: subscription_response(id: stripe_subscription_id, cancel_at_period_end: true)
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
      query:,
      body: request_body
    ).to_return(
      status:,
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

  def coupon_response
    {
      id: 'Z4OV52SU',
      object: 'coupon',
      amount_off: nil,
      created: 1_675_979_976,
      currency: 'usd',
      duration: 'repeating',
      duration_in_months: 3,
      livemode: false,
      max_redemptions: nil,
      metadata: {},
      name: '25.5% off',
      percent_off: 25.5,
      redeem_by: nil,
      times_redeemed: 0,
      valid: true
    }.to_json
  end

  def subscription_response(id:,
                            status: 'active',
                            pause_collection: nil,
                            cancel_at_period_end: false,
                            discount: nil)
    {
      id:,
      latest_invoice: 'il_1Kooo9EbKIwsJiGZ9Ip7Efqr',
      items: { data: [id: 'stripe-subscription-item-id'] },
      status:,
      current_period_start: 2.weeks.ago.to_i,
      current_period_end: 2.weeks.from_now.to_i,
      cancel_at: nil,
      canceled_at: Time.current.to_i,
      cancel_at_period_end:,
      pause_collection:,
      discount:
    }.to_json
  end

  def invoice_response(params)
    {
      amount_due: 1239,
      currency: 'usd',
      customer: params[:customer_id] || 'cus_AJ6y81jMo1Na22',
      payment_intent: 'pi_1Kooo9EbKIwsJiGZCM',
      lines: {
        object: 'list',
        data: [
          {
            id: params[:stripe_invoice_id] || 'il_1Kooo9EbKIwsJiGZ9Ip7Efqr',
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
      subscription: params[:subscription_id] || 'sub_IwsJiGZ9Ip7Ef',
      subtotal: 1239,
      tax: nil,
      tax_percent: nil,
      total: 1239,
      total_discount_amounts: [{
        amount: 123
      }]
    }.to_json
  end
end
