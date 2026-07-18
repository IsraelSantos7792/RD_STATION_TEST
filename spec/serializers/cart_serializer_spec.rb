require 'rails_helper'

RSpec.describe CartSerializer do
  it 'serializes the cart with its items and computed total' do
    cart = Cart.create!
    product = Product.create!(name: 'Widget', price: 2.5)
    cart.cart_items.create!(product: product, quantity: 4)

    json = described_class.new(cart).as_json

    expect(json).to eq(
      id: cart.id,
      products: [
        { id: product.id, name: 'Widget', quantity: 4, unit_price: 2.5, total_price: 10.0 }
      ],
      total_price: 10.0
    )
  end

  it 'serializes an empty cart with total_price zero' do
    cart = Cart.create!

    json = described_class.new(cart).as_json

    expect(json).to eq(id: cart.id, products: [], total_price: 0)
  end
end
