class CartsController < ApplicationController
  def show
    cart = current_cart_or_create
    render json: serialize_cart(cart), status: :ok
  end

  def create
    cart = current_cart_or_create
    cart.touch_interaction!

    add_item_to_cart!(cart, params.require(:product_id), params[:quantity])
    render json: serialize_cart(cart), status: :ok
  end

  def add_item
    cart = current_cart_or_create
    cart.touch_interaction!

    add_item_to_cart!(cart, params.require(:product_id), params[:quantity])
    render json: serialize_cart(cart), status: :ok
  end

  def remove_item
    cart = current_cart_or_create
    product_id = params.require(:product_id)

    cart_item = cart.cart_items.find_by(product_id: product_id)
    unless cart_item
      return render json: { error: "Product not in cart" }, status: :not_found
    end

    removed_total = cart_item.product.price * cart_item.quantity
    cart_item.destroy!

    cart.total_price = [((cart.total_price || 0) - removed_total), 0].max
    cart.touch_interaction!
    cart.save!

    render json: serialize_cart(cart), status: :ok
  end

  def destroy
    cart = current_cart_or_create
    cart.destroy
    session.delete(:cart_id)
    render json: { message: "Cart destroyed" }, status: :ok
  end

  private

  def current_cart_or_create
    cart = session[:cart_id] && Cart.find_by(id: session[:cart_id])
    return cart if cart

    cart = Cart.create!(total_price: 0)
    session[:cart_id] = cart.id
    cart
  end

  def serialize_cart(cart)
    {
      id: cart.id,
      products: cart.cart_items.includes(:product).map do |cart_item|
        {
          id: cart_item.product.id,
          name: cart_item.product.name,
          quantity: cart_item.quantity,
          unit_price: cart_item.product.price,
          total_price: cart_item.product.price * cart_item.quantity
        }
      end,
      total_price: cart.total_price || 0
    }
  end

  def add_item_to_cart!(cart, product_id, quantity_param)
    product = Product.find(product_id)
    quantity = quantity_param.to_i
    quantity = 1 if quantity < 1

    cart_item = cart.cart_items.find_or_initialize_by(product_id: product.id)
    cart_item.quantity =
      if cart_item.new_record?
        quantity
      else
        cart_item.quantity + quantity
      end
    cart_item.save!

    cart.total_price = (cart.total_price || 0) + (product.price * quantity)
    cart.save!
  end
end
