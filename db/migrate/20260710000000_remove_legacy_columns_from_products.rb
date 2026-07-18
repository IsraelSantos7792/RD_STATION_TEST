class RemoveLegacyColumnsFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_reference :products, :cart, foreign_key: true, index: true
    remove_column :products, :quantity, :integer, default: 1
    remove_column :products, :total_price, :decimal, precision: 17, scale: 2
  end
end
