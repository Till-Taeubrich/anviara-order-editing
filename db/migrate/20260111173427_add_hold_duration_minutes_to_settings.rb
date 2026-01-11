class AddHoldDurationMinutesToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :hold_duration_minutes, :integer, null: false, default: 30
  end
end
