class AddShopifyCreatedAtToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :shopify_created_at, :datetime
  end
end
