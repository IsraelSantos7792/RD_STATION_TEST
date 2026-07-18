require 'rails_helper'

RSpec.describe Carts::RemoveItemService do
  let(:cart) { Cart.create! }
  let(:product) { Product.create!(name: 'Widget', price: 10) }

  it 'removes the product from the cart' do
    cart.cart_items.create!(product: product, quantity: 2)

    described_class.call(cart: cart, product_id: product.id)

    expect(cart.cart_items.find_by(product_id: product.id)).to be_nil
  end

  it 'touches the cart interaction timestamp' do
    cart.cart_items.create!(product: product, quantity: 2)

    expect { described_class.call(cart: cart, product_id: product.id) }
      .to change { cart.reload.last_interaction_at }.from(nil)
  end

  it 'raises ProductNotInCartError when the product is not in the cart' do
    expect { described_class.call(cart: cart, product_id: product.id) }
      .to raise_error(ProductNotInCartError)
  end
end
