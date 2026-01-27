# frozen_string_literal: true

class FulfillmentOrdersRoutingCompleteJob < ApplicationJob
  queue_as :critical

  retry_on ShopifyGraphql::TooManyRequests, wait: :polynomially_longer, attempts: 5
  retry_on ShopifyGraphql::ServerError, wait: :polynomially_longer, attempts: 5
  discard_on ShopifyGraphql::UserError

  def perform(shop_domain:, webhook:)
    shop = Shop.find_by!(shopify_domain: shop_domain)

    shop.with_shopify_session do
      FulfillmentOrder.from_shopify!(shop, webhook["fulfillment_order"])
    end
  end
end
