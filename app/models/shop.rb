# frozen_string_literal: true

class Shop < ActiveRecord::Base
  include ShopifyApp::ShopSessionStorageWithScopes

  has_many :orders, dependent: :destroy
  has_many :fulfillment_orders, dependent: :destroy
  has_one :settings, dependent: :destroy

  def setup!
    settings || create_settings!
  end

  def api_version
    ShopifyApp.configuration.api_version
  end

  def shop_handle
    shopify_domain.split(".myshopify.com").first
  end

  def admin_url(path = nil)
    "https://admin.shopify.com/store/#{shop_handle}#{path}"
  end

  def should_hold_fulfillment_order?
    true # TODO: implement time window logic for same day delivery support
  end
end
