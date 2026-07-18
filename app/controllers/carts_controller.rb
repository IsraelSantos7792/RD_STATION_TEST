class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: CartSerializer.new(@cart), status: :ok
  end

  def create
    add_item
  end

  def add_item
    @cart = Carts::AddItemService.call(
      cart: @cart,
      product_id: cart_params.require(:product_id),
      quantity: cart_params[:quantity] || 1
    )
    render json: CartSerializer.new(@cart), status: :ok
  end

  def remove_item
    @cart = Carts::RemoveItemService.call(cart: @cart, product_id: cart_params.require(:product_id))
    render json: CartSerializer.new(@cart), status: :ok
  end

  def destroy
    @cart.destroy!
    session.delete(:cart_id)
    render json: { message: "Cart destroyed" }, status: :ok
  end

  private

  def set_cart
    @cart = Carts::FindOrCreateForSession.call(session: session)
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end
end
