# frozen_string_literal: true

class Webhooks::ComplianceController < ApplicationController
  include ShopifyApp::WebhookVerification

  def receive
    webhook = ShopifyAPI::Webhooks::Request.new(raw_body: request.raw_post, headers: request.headers.to_h)

    case webhook.topic
    when "customers/data_request"
      handle_data_request(webhook)
    when "customers/redact"
      handle_customer_redact(webhook)
    when "shop/redact"
      ShopRedactJob.set(wait: 48.hours).perform_later(shop_domain: webhook.shop, requested_at: Time.current)
    end

    head(:no_content)
  end

  private

  def handle_data_request(webhook)
    shop = Shop.find_by(shopify_domain: webhook.shop)
    return unless shop

    orders = find_orders(shop, webhook.parsed_body["orders_requested"])
    customer_id = webhook.parsed_body.dig("customer", "id")
    data = orders.map { |o| { shopify_id: o.shopify_id, created_at: o.created_at } }

    Rails.logger.info(
      "[Compliance] customers/data_request shop=#{webhook.shop} " \
        "customer_id=#{customer_id} orders_found=#{orders.count} data=#{data}",
    )
  end

  def handle_customer_redact(webhook)
    shop = Shop.find_by(shopify_domain: webhook.shop)
    return unless shop

    orders = find_orders(shop, webhook.parsed_body["orders_to_redact"])
    customer_id = webhook.parsed_body.dig("customer", "id")

    Rails.logger.info(
      "[Compliance] customers/redact shop=#{webhook.shop} " \
        "customer_id=#{customer_id} destroying_orders=#{orders.count}",
    )

    orders.destroy_all
  end

  def find_orders(shop, numeric_ids)
    order_gids = Array(numeric_ids).map { |id| "gid://shopify/Order/#{id}" }
    shop.orders.where(shopify_id: order_gids)
  end
end
