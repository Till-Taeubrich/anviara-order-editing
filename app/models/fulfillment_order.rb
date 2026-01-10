# frozen_string_literal: true

class FulfillmentOrder < ApplicationRecord
  belongs_to :shop
  belongs_to :order

  validates :shopify_id, presence: true, uniqueness: true
  validates :status, presence: true

  def self.from_shopify(shop, payload)
    if shop.should_hold_fulfillment_order?
      hold_immediately_and_persist(shop, payload)
    else
      FulfillmentOrderPersistJob.perform_later(shop_id: shop.id, payload:)
    end

    nil
  end

  private_class_method def self.hold_immediately_and_persist(shop, payload)
    data = HoldFulfillmentOrder.call(fulfillment_order_id: payload["id"]).data.fulfillmentOrder
    persist(shop, payload["id"], data.order.id, data.status)
  end

  def self.persist_from_shopify(shop, payload)
    data = GetFulfillmentOrder.call(fulfillment_order_id: payload["id"]).data
    persist(shop, payload["id"], data.order.id, data.status)
  end

  private_class_method def self.persist(shop, shopify_id, order_shopify_id, status)
    order = shop.orders.find_or_create_by!(shopify_id: order_shopify_id)
    shop.fulfillment_orders.find_or_create_by!(shopify_id:) do |fo|
      fo.order = order
      fo.status = status
    end
  end
end
