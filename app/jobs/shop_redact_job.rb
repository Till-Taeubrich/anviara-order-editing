# frozen_string_literal: true

class ShopRedactJob < ApplicationJob
  queue_as :low

  discard_on ActiveRecord::RecordNotFound

  def perform(shop_domain:, requested_at:)
    shop = Shop.find_by!(shopify_domain: shop_domain)

    return if shop.updated_at > requested_at

    shop.destroy!
  end
end
