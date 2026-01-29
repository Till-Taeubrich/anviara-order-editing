# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Order::AddressEditable, type: :model) do
  let(:shop) do
    s = Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token")
    s.create_settings!(hold_duration_minutes: 30)
    s
  end
  let(:order_id) { "gid://shopify/Order/123" }

  let(:address) do
    { firstName: "Jane", lastName: "Doe", address1: "123 Main St", city: "Ottawa", zip: "K1A 0B1" }
  end

  before do
    allow_any_instance_of(Shop).to(receive(:with_shopify_session).and_yield)
  end

  describe ".update_shipping_address" do
    context "when order exists and edit window expired" do
      it "returns failure without calling the API" do
        Order.create!(shopify_id: order_id, shop: shop, shopify_created_at: 45.minutes.ago)

        expect(UpdateOrderAddress).not_to(receive(:call))

        result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

        expect(result.success).to(be(false))
        expect(result.errors).to(eq(["Editing window has expired"]))
      end
    end

    context "when order exists and within edit window" do
      it "proceeds with the API call" do
        Order.create!(shopify_id: order_id, shop: shop, shopify_created_at: 10.minutes.ago)

        graphql_order = double("order", statusPageUrl: "https://example.com/status")
        graphql_data = double("data", userErrors: [], order: graphql_order)
        allow(UpdateOrderAddress).to(receive(:call).and_return(double("result", data: graphql_data)))

        result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

        expect(result.success).to(be(true))
      end
    end

    context "when order does not exist in local database" do
      it "proceeds with the API call" do
        graphql_order = double("order", statusPageUrl: "https://example.com/status")
        graphql_data = double("data", userErrors: [], order: graphql_order)
        allow(UpdateOrderAddress).to(receive(:call).and_return(double("result", data: graphql_data)))

        result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

        expect(result.success).to(be(true))
      end
    end
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
      error = ShopifyGraphql::UserError.new
      allow(UpdateOrderAddress).to(receive(:call).and_raise(error, "Invalid address"))

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
