require 'rails_helper'

describe 'GET api/v1/subscriptions/preview_prorate' do
  let(:user) { create(:user) }
  let(:product) { create(:product, credits: 4, product_type: 'recurring') }
  let(:new_product) { create(:product, :unlimited, stripe_price_id: 100) }
  let(:promo_code) { create(:promo_code) }
  let!(:active_subscription) do
    create(
      :subscription,
      user:,
      product:
    )
  end
  let(:items) do
    [{
      id: active_subscription.stripe_item_id,
      price: new_product.stripe_price_id
    }]
  end
  let(:proration_date) { Time.now.to_i }

  let(:params) do
    { product_id: new_product.id, promo_code: promo_code.code }
  end

  let(:response_body) do
    JSON.parse(subject.body).with_indifferent_access
  end

  subject do
    get preview_prorate_api_v1_subscriptions_path, params:, headers: auth_headers, as: :json
    response
  end

  before do
    Timecop.freeze(Time.current)
    StripeMocker.new.upcoming_invoice(
      user.stripe_id,
      active_subscription.stripe_id,
      items,
      proration_date,
      promo_code
    )
  end

  after { Timecop.return }

  it 'returns success' do
    is_expected.to be_successful
  end

  it 'returns no subscriptions' do
    expect(response_body[:prorate]).to include_json(
      subtotal: 12.39,
      tax: nil,
      tax_percent: nil,
      total: 12.39
    )
  end
end
