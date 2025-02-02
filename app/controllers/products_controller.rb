# frozen_string_literal: true

class ProductsController < AuthenticatedController
  def index
    @products = current_shop.with_shopify_session do
      GetProducts.call.data
    end
  end
end
