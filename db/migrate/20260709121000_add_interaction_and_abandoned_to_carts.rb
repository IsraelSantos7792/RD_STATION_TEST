class AddInteractionAndAbandonedToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_interaction_at, :datetime
    add_column :carts, :abandoned_at, :datetime

    add_index :carts, :last_interaction_at
    add_index :carts, :abandoned_at
  end
end

