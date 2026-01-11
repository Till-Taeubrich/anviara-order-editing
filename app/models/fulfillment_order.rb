# frozen_string_literal: true

class FulfillmentOrder < ApplicationRecord
  belongs_to :shop
  belongs_to :order

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
    shopify_created_at = Time.parse(data.createdAt)
    record = persist!(shop, payload["id"], data.order.id, data.status, held_at: Time.current, shopify_created_at:)

    release_time = shopify_created_at + 30.minutes
    ReleaseFulfillmentOrderHoldJob.set(wait_until: release_time).perform_later(fulfillment_order_id: record.id)
  end

  def self.persist_from_shopify!(shop, payload)
    data = GetFulfillmentOrder.call(fulfillment_order_id: payload["id"]).data
    shopify_created_at = Time.parse(data.createdAt)
    persist!(shop, payload["id"], data.order.id, data.status, shopify_created_at:)
  end

  private_class_method def self.persist!(shop, shopify_id, order_shopify_id, status, held_at: nil,
    shopify_created_at: nil)
    order = shop.orders.find_or_create_by!(shopify_id: order_shopify_id)
    record = shop.fulfillment_orders.find_or_initialize_by!(shopify_id:)
    record.order = order
    record.status = status
    record.held_at = held_at if held_at
    record.shopify_created_at = shopify_created_at if shopify_created_at
    record.save!
    record
  end
end
