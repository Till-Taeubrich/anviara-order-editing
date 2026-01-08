# frozen_string_literal: true

class FulfillmentOrdersRoutingCompleteJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by!(shopify_domain: shop_domain)

    puts("[FulfillmentOrdersRoutingComplete] Webhook received for #{webhook.to_json}")

    # TODO: Implement actual fulfillment order handling
  end
end
