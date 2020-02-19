class PurchaseDecorator < Draper::Decorator
  delegate_all

  def final_price
    price - discount
  end
end
