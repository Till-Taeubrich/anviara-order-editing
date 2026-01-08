class CreateFulfillmentOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :fulfillment_orders do |t|
      t.timestamps
      t.string :shopify_id, null: false
      t.string :status, null: false
      t.references :shop, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
    end

    add_index :fulfillment_orders, :shopify_id, unique: true
  end
end
