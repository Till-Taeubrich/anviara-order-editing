class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.references :shop, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
