class ProductNotInCartError < ApplicationError
  def initialize(product_id)
    super("Product #{product_id} is not in the cart")
  end

  def http_status
    :not_found
  end
end
