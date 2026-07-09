class AddQuantityAndTotalPriceToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :quantity, :integer, default: 1
    add_column :products, :total_price, :decimal, precision: 17, scale: 2
  end
end
