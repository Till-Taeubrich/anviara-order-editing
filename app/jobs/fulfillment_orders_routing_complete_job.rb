# frozen_string_literal: true

class FulfillmentOrdersRoutingCompleteJob < ApplicationJob
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by!(shopify_domain: shop_domain)
    fulfillment_order_id = webhook.dig("fulfillment_order", "id")

    shop.with_shopify_session do
      result = HoldFulfillmentOrder.call(fulfillment_order_id: fulfillment_order_id)

      puts("[FulfillmentOrdersRoutingComplete] Fulfillment order held for #{result.data}")
      puts("[FulfillmentOrdersRoutingComplete] Fulfillment order held for #{result.data.fulfillmentOrder.id}")
    end
  end
end
