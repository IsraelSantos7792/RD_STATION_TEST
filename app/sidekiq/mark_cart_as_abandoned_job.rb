class MarkCartAsAbandonedJob
  include Sidekiq::Job

  sidekiq_options queue: "default", retry: 5

  def perform(*args)
    abandoned_count = mark_inactive_carts_as_abandoned
    removed_count = remove_old_abandoned_carts

    Rails.logger.info(
      event: "cart_abandonment_sweep",
      abandoned_count: abandoned_count,
      removed_count: removed_count
    )
  end

  private

  def mark_inactive_carts_as_abandoned
    count = 0
    Cart.inactive_since_abandon_window.find_each do |cart|
      cart.mark_as_abandoned
      count += 1
    end
    count
  end

  def remove_old_abandoned_carts
    count = 0
    Cart.abandoned_since_removal_window.find_each do |cart|
      cart.remove_if_abandoned
      count += 1
    end
    count
  end
end
