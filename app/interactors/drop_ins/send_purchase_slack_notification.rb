module DropIns
  class SendPurchaseSlackNotification
    include Interactor

    def call
      user = context.user
      product = context.product

      return unless product.season_pass

      SlackService.new(user).season_pass_purchased(product)
    end
  end
end
