class ChargeUserException < StandardError
  def initialize(message)
    super(message)
  end
end
