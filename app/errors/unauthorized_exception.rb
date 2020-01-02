class UnauthorizedException < StandardError
  def initialize(message)
    super(message)
  end
end
