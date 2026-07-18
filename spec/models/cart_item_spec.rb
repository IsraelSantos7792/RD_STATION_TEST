require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { Cart.create! }
  let(:product) { Product.create!(name: 'Widget', price: 5) }

  describe 'validations' do
    it 'requires a positive integer quantity' do
      cart_item = described_class.new(cart: cart, product: product, quantity: 0)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("must be greater than 0")
    end

    it 'does not allow the same product twice in the same cart' do
      described_class.create!(cart: cart, product: product, quantity: 1)
      duplicate = described_class.new(cart: cart, product: product, quantity: 1)

      expect(duplicate.valid?).to be_falsey
      expect(duplicate.errors[:product_id]).to include("has already been taken")
    end
  end

  describe '#subtotal' do
    it 'multiplies the product price by the quantity' do
      cart_item = described_class.create!(cart: cart, product: product, quantity: 4)

      expect(cart_item.subtotal).to eq(20)
    end
  end
end
