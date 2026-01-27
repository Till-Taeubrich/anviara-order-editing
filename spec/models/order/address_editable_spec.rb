# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Order::AddressEditable, type: :model) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }
  let(:order) { Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop) }

  let(:address) do
    { firstName: "Jane", lastName: "Doe", address1: "123 Main St", city: "Ottawa", zip: "K1A 0B1" }
  end

  describe "#update_shipping_address" do
    it "returns success when no user errors" do
      graphql_order = double("order", statusPageUrl: "https://example.com/status")
      graphql_data = double("data", userErrors: [], order: graphql_order)
      mock_result = double("result", data: graphql_data)

      allow(UpdateOrderAddress).to(receive(:call).and_return(mock_result))
      allow(shop).to(receive(:with_shopify_session).and_yield)

      result = order.update_shipping_address(address: address)

      expect(result.success).to(be(true))
      expect(result.errors).to(eq([]))
      expect(result.status_page_url).to(eq("https://example.com/status"))
    end

    it "returns errors when user errors present" do
      user_error = double("userError", message: "Invalid address")
      graphql_data = double("data", userErrors: [user_error], order: nil)
      mock_result = double("result", data: graphql_data)

      allow(UpdateOrderAddress).to(receive(:call).and_return(mock_result))
      allow(shop).to(receive(:with_shopify_session).and_yield)

      result = order.update_shipping_address(address: address)

      expect(result.success).to(be(false))
      expect(result.errors).to(eq(["Invalid address"]))
      expect(result.status_page_url).to(be_nil)
    end
  end
end
