class RemoveTotalPriceFromCarts < ActiveRecord::Migration[7.1]
  def change
    remove_column :carts, :total_price, :decimal, precision: 17, scale: 2
  end
end
