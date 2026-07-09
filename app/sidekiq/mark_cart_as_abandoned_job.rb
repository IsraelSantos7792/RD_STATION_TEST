class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    mark_inactive_carts_as_abandoned
    remove_old_abandoned_carts
  end

  private

  def mark_inactive_carts_as_abandoned
    Cart.where(abandoned_at: nil)
        .where.not(last_interaction_at: nil)
        .where("last_interaction_at <= ?", 3.hours.ago)
        .find_each do |cart|
      cart.mark_as_abandoned
    end
  end

  def remove_old_abandoned_carts
    Cart.where.not(abandoned_at: nil)
        .where.not(last_interaction_at: nil)
        .where("last_interaction_at <= ?", 7.days.ago)
        .find_each do |cart|
      cart.remove_if_abandoned
    end
  end
end
