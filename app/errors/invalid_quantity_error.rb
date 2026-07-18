class InvalidQuantityError < ApplicationError
  def initialize(quantity)
    super("Quantity must be a positive integer, got #{quantity.inspect}")
  end

  def http_status
    :unprocessable_entity
  end
end
