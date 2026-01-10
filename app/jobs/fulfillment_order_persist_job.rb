# frozen_string_literal: true

class FulfillmentOrderPersistJob < ApplicationJob
  queue_as :default

  def perform(shop_id:, payload:)
    shop = Shop.find(shop_id)

    shop.with_shopify_session do
      FulfillmentOrder.persist_from_shopify(shop, payload)
    end
  end
end
