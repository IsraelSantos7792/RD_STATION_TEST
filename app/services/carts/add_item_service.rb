class Carts::AddItemService
  def self.call(cart:, product_id:, quantity: 1)
    new(cart: cart, product_id: product_id, quantity: quantity).call
  end

  def initialize(cart:, product_id:, quantity: 1)
    @cart = cart
    @product_id = product_id
    @quantity = normalize_quantity(quantity)
  end

  def call
    product = Product.find(product_id)

    ActiveRecord::Base.transaction do
      cart_item = cart.cart_items.find_or_initialize_by(product_id: product.id)
      cart_item.quantity = cart_item.new_record? ? quantity : cart_item.quantity + quantity
      cart_item.save!
      cart.touch_interaction!
    end

    Rails.logger.info(event: "cart_item_added", cart_id: cart.id, product_id: product.id, quantity: quantity)
    cart.reload
  end

  private

  attr_reader :cart, :product_id, :quantity

  def normalize_quantity(value)
    quantity = Integer(value)
    raise InvalidQuantityError, value if quantity < 1

    quantity
  rescue ArgumentError, TypeError
    raise InvalidQuantityError, value
  end
end
