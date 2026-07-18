class Cart < ApplicationRecord
  ABANDON_AFTER = 3.hours
  REMOVE_AFTER = 7.days

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  scope :inactive_since_abandon_window, -> {
    where(abandoned_at: nil)
      .where.not(last_interaction_at: nil)
      .where(last_interaction_at: ..ABANDON_AFTER.ago)
  }

  scope :abandoned_since_removal_window, -> {
    where.not(abandoned_at: nil)
      .where.not(last_interaction_at: nil)
      .where(last_interaction_at: ..REMOVE_AFTER.ago)
  }

  def total_price
    cart_items.includes(:product).sum(&:subtotal)
  end

  def touch_interaction!
    update!(last_interaction_at: Time.current, abandoned_at: nil)
  end

  def abandoned?
    abandoned_at.present?
  end

  def mark_as_abandoned
    return if abandoned?
    return if last_interaction_at.blank?
    return if last_interaction_at > ABANDON_AFTER.ago

    update!(abandoned_at: Time.current)
  end

  def remove_if_abandoned
    return unless abandoned?
    return if last_interaction_at.blank?
    return if last_interaction_at > REMOVE_AFTER.ago

    destroy!
  end
end
