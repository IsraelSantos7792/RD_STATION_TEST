class Carts::RemoveItemService
  def self.call(cart:, product_id:)
    new(cart: cart, product_id: product_id).call
  end

  def initialize(cart:, product_id:)
    @cart = cart
    @product_id = product_id
  end

  def call
    cart_item = cart.cart_items.find_by(product_id: product_id)
    raise ProductNotInCartError, product_id unless cart_item

    ActiveRecord::Base.transaction do
      cart_item.destroy!
      cart.touch_interaction!
    end

    Rails.logger.info(event: "cart_item_removed", cart_id: cart.id, product_id: product_id)
    cart.reload
  end

  private

  attr_reader :cart, :product_id
end
