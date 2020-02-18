class ChargeCard
  include Interactor

  def call
    StripeService.charge(context.user, context.payment_method, context.product, context.promo_code)
  end
end
