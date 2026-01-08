class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :shopify_id, null: false
      t.references :shop, null: false, foreign_key: true

      t.timestamps
    end

    add_index :orders, :shopify_id, unique: true
  end
end
