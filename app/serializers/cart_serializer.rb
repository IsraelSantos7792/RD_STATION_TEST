class CartSerializer
  def initialize(cart)
    @cart = cart
  end

  def as_json(*)
    {
      id: cart.id,
      products: cart_items.map { |cart_item| CartItemSerializer.new(cart_item).as_json },
      total_price: cart.total_price
    }
  end

  private

  attr_reader :cart

  def cart_items
    cart.cart_items.includes(:product)
  end
end
