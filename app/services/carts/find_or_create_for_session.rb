class Carts::FindOrCreateForSession
  def self.call(session:)
    new(session: session).call
  end

  def initialize(session:)
    @session = session
  end

  def call
    existing_cart || create_cart_for_session
  end

  private

  attr_reader :session

  def existing_cart
    return nil unless session[:cart_id]

    Cart.find_by(id: session[:cart_id])
  end

  def create_cart_for_session
    Cart.create!.tap { |cart| session[:cart_id] = cart.id }
  end
end
