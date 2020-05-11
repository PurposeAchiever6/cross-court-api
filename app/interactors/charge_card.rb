class ChargeCard
  include Interactor

  def call
    price = context.price
    return if price.zero?

    StripeService.charge(context.user, context.payment_method, price)
  end
end
