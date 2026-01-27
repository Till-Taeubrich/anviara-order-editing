# frozen_string_literal: true

module Api
  class ShippingAddressUpdatesController < BaseController
    skip_before_action :verify_session_token, only: :options

    def create
      order = @current_shop.orders.find_by!(shopify_id: params[:order_id])
      result = order.update_shipping_address(address: params[:address])

      if result.success
        render(json: { success: true, statusPageUrl: result.status_page_url })
      else
        render(json: { success: false, errors: result.errors }, status: :unprocessable_entity)
      end
    end

    def options
      head(:ok)
    end
  end
end
