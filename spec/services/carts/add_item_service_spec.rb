require 'rails_helper'

RSpec.describe Carts::AddItemService do
  let(:cart) { Cart.create! }
  let(:product) { Product.create!(name: 'Widget', price: 10) }

  it 'adds a new product to the cart' do
    described_class.call(cart: cart, product_id: product.id, quantity: 2)

    item = cart.cart_items.find_by(product_id: product.id)
    expect(item.quantity).to eq(2)
  end

  it 'increments the quantity when the product is already in the cart' do
    described_class.call(cart: cart, product_id: product.id, quantity: 2)
    described_class.call(cart: cart, product_id: product.id, quantity: 3)

    item = cart.cart_items.find_by(product_id: product.id)
    expect(item.quantity).to eq(5)
  end

  it 'defaults quantity to 1' do
    described_class.call(cart: cart, product_id: product.id)

    item = cart.cart_items.find_by(product_id: product.id)
    expect(item.quantity).to eq(1)
  end

  it 'touches the cart interaction timestamp' do
    expect { described_class.call(cart: cart, product_id: product.id) }
      .to change { cart.reload.last_interaction_at }.from(nil)
  end

  it 'raises ActiveRecord::RecordNotFound for an unknown product' do
    expect { described_class.call(cart: cart, product_id: -1, quantity: 1) }
      .to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'raises InvalidQuantityError for a zero quantity' do
    expect { described_class.call(cart: cart, product_id: product.id, quantity: 0) }
      .to raise_error(InvalidQuantityError)
  end

  it 'raises InvalidQuantityError for a negative quantity' do
    expect { described_class.call(cart: cart, product_id: product.id, quantity: -3) }
      .to raise_error(InvalidQuantityError)
  end

  it 'raises InvalidQuantityError for a non-numeric quantity' do
    expect { described_class.call(cart: cart, product_id: product.id, quantity: 'abc') }
      .to raise_error(InvalidQuantityError)
  end

  it 'does not persist a cart item when the quantity is invalid' do
    expect {
      begin
        described_class.call(cart: cart, product_id: product.id, quantity: 0)
      rescue InvalidQuantityError
        nil
      end
    }.not_to change { cart.cart_items.count }
  end
end
