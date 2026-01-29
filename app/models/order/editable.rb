# frozen_string_literal: true

module Order::Editable
  extend ActiveSupport::Concern

  def edit_window_expired?
    edit_window_closes_at <= Time.current
  end

  def edit_window_closes_at
    shopify_created_at + shop.settings.hold_duration_minutes.minutes
  end
end
