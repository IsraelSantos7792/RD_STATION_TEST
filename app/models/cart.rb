class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def touch_interaction!
    self.last_interaction_at = Time.current
    self.abandoned_at = nil
    save!
  end

  def abandoned?
    abandoned_at.present?
  end

  def mark_as_abandoned
    return if abandoned?
    return if last_interaction_at.blank?
    return if last_interaction_at > 3.hours.ago

    update!(abandoned_at: Time.current)
  end

  def remove_if_abandoned
    return unless abandoned?
    return if last_interaction_at.blank?
    return if last_interaction_at > 7.days.ago

    destroy!
  end
end
