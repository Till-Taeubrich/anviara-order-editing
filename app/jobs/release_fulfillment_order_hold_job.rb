# frozen_string_literal: true

class ReleaseFulfillmentOrderHoldJob < ApplicationJob
  queue_as :default

  retry_on ShopifyGraphql::TooManyRequests, wait: :polynomially_longer, attempts: 10
  retry_on ShopifyGraphql::ServerError, wait: :polynomially_longer, attempts: 10
  discard_on ShopifyGraphql::UserError

  def perform(fulfillment_order_id:)
    fulfillment_order = FulfillmentOrder.find(fulfillment_order_id)

    fulfillment_order.shop.with_shopify_session do
      result = ReleaseFulfillmentOrderHold.call(fulfillment_order_id: fulfillment_order.shopify_id)
      fulfillment_order.update!(status: result.data.fulfillmentOrder.status)
    end
  end
end
