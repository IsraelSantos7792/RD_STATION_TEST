require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe '#total_price' do
    it 'is zero for an empty cart' do
      cart = described_class.create!

      expect(cart.total_price).to eq(0)
    end

    it 'is always derived from the current cart items, never stored' do
      cart = described_class.create!
      product = Product.create!(name: 'Widget', price: 10.5)
      cart.cart_items.create!(product: product, quantity: 3)

      expect(cart.total_price).to eq(31.5)
    end
  end

  describe '#touch_interaction!' do
    it 'updates last_interaction_at and clears abandoned_at' do
      cart = described_class.create!(abandoned_at: 1.day.ago)

      cart.touch_interaction!

      expect(cart.last_interaction_at).to be_within(1.second).of(Time.current)
      expect(cart.abandoned_at).to be_nil
    end
  end

  describe '#mark_as_abandoned' do
    let(:shopping_cart) { described_class.create!(last_interaction_at: Time.current) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update!(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end

    it 'does not mark as abandoned if still within the interaction window' do
      shopping_cart.update!(last_interaction_at: 1.hour.ago)
      expect { shopping_cart.mark_as_abandoned }.not_to change { shopping_cart.abandoned? }
    end
  end

  describe '#remove_if_abandoned' do
    let(:shopping_cart) { described_class.create!(last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end

    it 'keeps the cart if not abandoned yet' do
      shopping_cart

      expect { shopping_cart.remove_if_abandoned }.not_to change { Cart.count }
    end
  end
end
