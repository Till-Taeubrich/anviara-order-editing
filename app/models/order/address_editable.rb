# frozen_string_literal: true

module Order::AddressEditable
  extend ActiveSupport::Concern

  AddressUpdateResult = Data.define(:success, :errors, :status_page_url, :retryable) do
    def self.success(status_page_url:)
      new(success: true, errors: [], status_page_url: status_page_url, retryable: false)
    end

    def self.failure(errors:, retryable: false)
      new(success: false, errors: errors, status_page_url: nil, retryable: retryable)
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
      shop.with_shopify_session do
        AddressUpdateResult.from_graphql(
          UpdateOrderAddress.call(order_id:, shipping_address: address),
        )
      end
    rescue ShopifyGraphql::UserError => e
      retryable = e.message.include?("Order does not exist")
      AddressUpdateResult.failure(errors: retryable ? [] : [e.message], retryable: retryable)
    end
  end
end
