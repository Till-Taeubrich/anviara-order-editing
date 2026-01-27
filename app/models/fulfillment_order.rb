# frozen_string_literal: true

class FulfillmentOrder < ApplicationRecord
  belongs_to :shop
  belongs_to :order, optional: true

  validates :shopify_id, presence: true, uniqueness: true
  validates :status, presence: true

  def self.from_shopify!(shop, payload)
    if shop.should_hold_fulfillment_order?
      hold_immediately_and_persist!(shop, payload)
    else
      FulfillmentOrderPersistJob.perform_later(shop_id: shop.id, payload:)
    end

    nil
  end

  private_class_method def self.hold_immediately_and_persist!(shop, payload)
    data = HoldFulfillmentOrder.call(fulfillment_order_id: payload["id"]).data.fulfillmentOrder
    order_shopify_created_at = Time.parse(data.order.createdAt)
    record = persist!(shop, payload["id"], data.order.id, data.status, order_shopify_created_at:, held_at: Time.current)

    release_time = order_shopify_created_at + shop.settings.hold_duration_minutes.minutes
    ReleaseFulfillmentOrderHoldJob.set(wait_until: release_time).perform_later(fulfillment_order_id: record.id)
  end

  def self.persist_from_shopify!(shop, payload)
    data = GetFulfillmentOrder.call(fulfillment_order_id: payload["id"]).data
    order_shopify_created_at = Time.parse(data.order.createdAt)
    persist!(shop, payload["id"], data.order.id, data.status, order_shopify_created_at:)
  end

  private_class_method def self.persist!(shop, shopify_id, order_shopify_id, status, order_shopify_created_at: nil,
    held_at: nil)
    order = shop.orders.find_or_create_by!(shopify_id: order_shopify_id) do |o|
      o.shopify_created_at = order_shopify_created_at if order_shopify_created_at
    end

    FulfillmentOrder.find_or_create_by!(shop: shop, shopify_id: shopify_id) do |record|
      record.order = order
      record.status = status
      record.held_at = held_at
    end
  end
end
