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
  end

  def update_shipping_address(address:)
    shop.with_shopify_session do
      result = UpdateOrderAddress.call(order_id: shopify_id, shipping_address: address)

      if result.data.userErrors.any?
        AddressUpdateResult.failure(errors: result.data.userErrors.map(&:message))
      else
        AddressUpdateResult.success(status_page_url: result.data.order.statusPageUrl)
      end
    end
  end
end
