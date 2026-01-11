# frozen_string_literal: true

class FulfillmentOrderPersistJob < ApplicationJob
  queue_as :default

  retry_on ShopifyGraphql::TooManyRequests, wait: :polynomially_longer, attempts: 5
  retry_on ShopifyGraphql::ServerError, wait: :polynomially_longer, attempts: 5

  def perform(shop_id:, payload:)
    shop = Shop.find(shop_id)

    shop.with_shopify_session do
      FulfillmentOrder.persist_from_shopify!(shop, payload)
    end
  end
end
