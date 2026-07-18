require 'rails_helper'

RSpec.describe Carts::FindOrCreateForSession do
  it 'creates a new cart and stores its id in the session when none exists' do
    session = {}

    cart = described_class.call(session: session)

    expect(cart).to be_persisted
    expect(session[:cart_id]).to eq(cart.id)
  end

  it 'reuses the cart already referenced by the session' do
    existing_cart = Cart.create!
    session = { cart_id: existing_cart.id }

    cart = described_class.call(session: session)

    expect(cart).to eq(existing_cart)
  end

  it 'creates a new cart when the session references a cart that no longer exists' do
    session = { cart_id: -1 }

    cart = described_class.call(session: session)

    expect(cart).to be_persisted
    expect(session[:cart_id]).to eq(cart.id)
  end
end
