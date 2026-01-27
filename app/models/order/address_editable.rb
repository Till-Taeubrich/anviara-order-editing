# frozen_string_literal: true

module Order::AddressEditable
  extend ActiveSupport::Concern

  AddressUpdateResult = Data.define(:success, :errors, :status_page_url) do
    def self.success(status_page_url:)
      new(success: true, errors: [], status_page_url: status_page_url)
    end

    def self.failure(errors:)
      new(success: false, errors: errors, status_page_url: nil)
    end

    def self.from_graphql(result)
      if result.data.userErrors.any?
        failure(errors: result.data.userErrors.map(&:message))
      else
        success(status_page_url: result.data.order.statusPageUrl)
      end
    end
  end

  class_methods do
    def update_shipping_address(shop:, order_id:, address:)
      order = shop.orders.find_by(shopify_id: order_id)
      return order.update_shipping_address(address:) if order

      call_update_address(shop:, order_id:, address:)
    end

    def call_update_address(shop:, order_id:, address:)
      shop.with_shopify_session do
        AddressUpdateResult.from_graphql(
          UpdateOrderAddress.call(order_id:, shipping_address: address),
        )
      end
    end
  end

  def update_shipping_address(address:)
    self.class.call_update_address(shop:, order_id: shopify_id, address:)
  end
end
