# frozen_string_literal: true

module Api
  class ShippingAddressUpdatesController < BaseController
    skip_before_action :verify_session_token, only: :options

    def create
      result = Order.update_shipping_address(
        shop: @current_shop,
        order_id: params[:order_id],
        address: params[:address],
      )

      if result.success
        render(json: { success: true, statusPageUrl: result.status_page_url })
      else
        render(
          json: {
            success: false,
            errors: result.errors,
            retryable: result.retryable,
            fieldErrors: result.field_errors,
          },
          status: :unprocessable_entity,
        )
      end
    end

    def options
      head(:ok)
    end
  end
end
