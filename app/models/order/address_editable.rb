# frozen_string_literal: true

module Order::AddressEditable
  extend ActiveSupport::Concern

  AddressUpdateResult = Data.define(:success, :errors, :status_page_url, :retryable, :field_errors) do
    def self.success(status_page_url:)
      new(success: true, errors: [], status_page_url:, retryable: false, field_errors: [])
    end

    def self.failure(errors:, retryable: false, field_errors: [])
      new(success: false, errors:, status_page_url: nil, retryable:, field_errors:)
    end
  end

  class_methods do
    def update_shipping_address(shop:, order_id:, address:)
      order = shop.orders.find_by(shopify_id: order_id)

      return AddressUpdateResult.failure(errors: ["Editing window has expired"]) if order&.edit_window_expired?

      shop.with_shopify_session do
        result = UpdateOrderAddress.call(order_id:, shipping_address: address)
        AddressUpdateResult.success(status_page_url: result.data.order.statusPageUrl)
      end
    rescue ShopifyGraphql::UserError => e
      retryable = e.message.include?("Order does not exist")
      zip_error = e.message.include?("postal code")
      field_errors = zip_error ? ["zip"] : []
      generic_errors = zip_error ? [] : [e.message]

      AddressUpdateResult.failure(
        errors: retryable ? [] : generic_errors,
        retryable:,
        field_errors:,
      )
    end
  end
end
