require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  it "marks inactive carts as abandoned and removes very old ones" do
    inactive_cart = Cart.create!(total_price: 0, last_interaction_at: 4.hours.ago)
    old_cart = Cart.create!(total_price: 0, last_interaction_at: 8.days.ago, abandoned_at: 8.days.ago)

    described_class.new.perform

    expect(inactive_cart.reload).to be_abandoned
    expect(Cart.where(id: old_cart.id)).to be_empty
  end
end
