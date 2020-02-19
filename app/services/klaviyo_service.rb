require 'rack/klaviyo'

class KlaviyoService
  attr_reader :client

  def initialize
    @client = Klaviyo::Client.new(ENV['KLAVIYO_API_KEY'])
  end

  def purchase_placed(purchase)
    user_email = purchase.user_email
    client.track(
      'Purchase Placed',
      email: user_email,
      order_price: purchase.price.to_i,
      customer_properties: {
        email: user_email,
        first_name: purchase.user_name,
        phone_number: purchase.user_phone_number
      }
    )
  end
end
