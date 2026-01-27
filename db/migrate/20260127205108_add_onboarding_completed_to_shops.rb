class AddOnboardingCompletedToShops < ActiveRecord::Migration[8.0]
  def change
    add_column :shops, :onboarding_completed, :boolean, default: false, null: false
  end
end
