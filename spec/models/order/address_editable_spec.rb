# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Order::AddressEditable, type: :model) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }
  let(:order_id) { "gid://shopify/Order/123" }

  let(:address) do
    { firstName: "Jane", lastName: "Doe", address1: "123 Main St", city: "Ottawa", zip: "K1A 0B1" }
  end

  before do
    allow_any_instance_of(Shop).to(receive(:with_shopify_session).and_yield)
  end

  describe ".update_shipping_address" do
    it "returns success when no user errors" do
      graphql_order = double("order", statusPageUrl: "https://example.com/status")
      graphql_data = double("data", userErrors: [], order: graphql_order)
      allow(UpdateOrderAddress).to(receive(:call).and_return(double("result", data: graphql_data)))

      result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

      expect(result.success).to(be(true))
      expect(result.status_page_url).to(eq("https://example.com/status"))
      expect(result.retryable).to(be(false))
    end

    it "returns errors when user errors present" do
      user_error = double("userError", message: "Invalid address")
      error_data = double("data", userErrors: [user_error], order: nil)
      allow(UpdateOrderAddress).to(receive(:call).and_return(double("result", data: error_data)))

      result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

      expect(result.success).to(be(false))
      expect(result.errors).to(eq(["Invalid address"]))
      expect(result.retryable).to(be(false))
    end

    it "returns retryable failure with no errors when order does not exist yet" do
      error = ShopifyGraphql::UserError.new
      allow(UpdateOrderAddress).to(receive(:call).and_raise(
        error,
        "Failed. Response message = Order does not exist. Fields = [\"id\"].",
      ))

      result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

      expect(result.success).to(be(false))
      expect(result.errors).to(be_empty)
      expect(result.retryable).to(be(true))
    end

    it "returns non-retryable failure for other ShopifyGraphql user errors" do
      error = ShopifyGraphql::UserError.new
      allow(UpdateOrderAddress).to(receive(:call).and_raise(error, "Some other error"))

      result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

      expect(result.success).to(be(false))
      expect(result.errors).to(eq(["Some other error"]))
      expect(result.retryable).to(be(false))
    end
  end
end
