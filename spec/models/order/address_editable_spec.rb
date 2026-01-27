# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Order::AddressEditable, type: :model) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }
  let(:order_id) { "gid://shopify/Order/123" }

  let(:address) do
    { firstName: "Jane", lastName: "Doe", address1: "123 Main St", city: "Ottawa", zip: "K1A 0B1" }
  end

  let(:graphql_order) { double("order", statusPageUrl: "https://example.com/status") }
  let(:success_data) { double("data", userErrors: [], order: graphql_order) }
  let(:success_graphql) { double("result", data: success_data) }

  before do
    allow_any_instance_of(Shop).to(receive(:with_shopify_session).and_yield)
  end

  describe ".update_shipping_address" do
    context "when order exists locally" do
      let!(:order) { Order.create!(shopify_id: order_id, shop: shop) }

      it "updates via the order instance" do
        allow(UpdateOrderAddress).to(receive(:call).and_return(success_graphql))

        result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

        expect(result.success).to(be(true))
        expect(result.status_page_url).to(eq("https://example.com/status"))
      end
    end

    context "when order not yet synced" do
      it "calls Shopify directly and returns success" do
        allow(UpdateOrderAddress).to(receive(:call).and_return(success_graphql))

        result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

        expect(result.success).to(be(true))
        expect(result.status_page_url).to(eq("https://example.com/status"))
      end

      it "returns errors when user errors present" do
        user_error = double("userError", message: "Invalid address")
        error_data = double("data", userErrors: [user_error], order: nil)
        allow(UpdateOrderAddress).to(receive(:call).and_return(double("result", data: error_data)))

        result = Order.update_shipping_address(shop: shop, order_id: order_id, address: address)

        expect(result.success).to(be(false))
        expect(result.errors).to(eq(["Invalid address"]))
      end
    end
  end

  describe "#update_shipping_address" do
    let!(:order) { Order.create!(shopify_id: order_id, shop: shop) }

    it "returns success when no user errors" do
      allow(UpdateOrderAddress).to(receive(:call).and_return(success_graphql))

      result = order.update_shipping_address(address: address)

      expect(result.success).to(be(true))
      expect(result.status_page_url).to(eq("https://example.com/status"))
    end

    it "returns errors when user errors present" do
      user_error = double("userError", message: "Invalid address")
      error_data = double("data", userErrors: [user_error], order: nil)
      allow(UpdateOrderAddress).to(receive(:call).and_return(double("result", data: error_data)))

      result = order.update_shipping_address(address: address)

      expect(result.success).to(be(false))
      expect(result.errors).to(eq(["Invalid address"]))
    end
  end
end
