# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Api::ShippingAddressUpdatesController, type: :request) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }
  let(:order) { Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop) }

  let(:valid_address) do
    { firstName: "Jane", lastName: "Doe", address1: "123 Main St", city: "Ottawa", zip: "K1A 0B1" }
  end

  let(:jwt_payload) do
    instance_double(ShopifyAPI::Auth::JwtPayload, shopify_domain: shop.shopify_domain)
  end

  before do
    allow(ShopifyAPI::Auth::JwtPayload).to(receive(:new).with("valid-token").and_return(jwt_payload))
  end

  describe "POST /api/shipping_address_updates" do
    context "with valid session token" do
      it "updates the address successfully" do
        order # ensure order exists
        graphql_order = double("order", statusPageUrl: "https://example.com/status")
        graphql_data = double("data", userErrors: [], order: graphql_order)
        mock_graphql = double("result", data: graphql_data)

        allow(UpdateOrderAddress).to(receive(:call).and_return(mock_graphql))
        allow(shop).to(receive(:with_shopify_session).and_yield)

        post(
          "/api/shipping_address_updates",
          params: { order_id: order.shopify_id, address: valid_address },
          headers: { "Authorization" => "Bearer valid-token" },
          as: :json,
        )

        expect(response).to(have_http_status(:ok))
        body = JSON.parse(response.body)
        expect(body["success"]).to(be(true))
        expect(body["statusPageUrl"]).to(eq("https://example.com/status"))
      end

      it "returns errors on user errors" do
        order
        user_error = double("userError", message: "Invalid address")
        graphql_data = double("data", userErrors: [user_error], order: nil)
        mock_graphql = double("result", data: graphql_data)

        allow(UpdateOrderAddress).to(receive(:call).and_return(mock_graphql))
        allow(shop).to(receive(:with_shopify_session).and_yield)

        post(
          "/api/shipping_address_updates",
          params: { order_id: order.shopify_id, address: valid_address },
          headers: { "Authorization" => "Bearer valid-token" },
          as: :json,
        )

        expect(response).to(have_http_status(:unprocessable_entity))
        body = JSON.parse(response.body)
        expect(body["success"]).to(be(false))
        expect(body["errors"]).to(eq(["Invalid address"]))
      end

      it "returns 404 when order not found" do
        post(
          "/api/shipping_address_updates",
          params: { order_id: "gid://shopify/Order/999", address: valid_address },
          headers: { "Authorization" => "Bearer valid-token" },
          as: :json,
        )

        expect(response).to(have_http_status(:not_found))
        body = JSON.parse(response.body)
        expect(body["success"]).to(be(false))
      end
    end

    context "without session token" do
      it "returns 401" do
        post("/api/shipping_address_updates", params: { order_id: "gid://shopify/Order/123" }, as: :json)

        expect(response).to(have_http_status(:unauthorized))
        body = JSON.parse(response.body)
        expect(body["errors"]).to(include("Missing session token"))
      end
    end

    context "with invalid session token" do
      it "returns 401" do
        allow(ShopifyAPI::Auth::JwtPayload).to(
          receive(:new).with("bad-token").and_raise(ShopifyAPI::Errors::InvalidJwtTokenError),
        )

        post(
          "/api/shipping_address_updates",
          params: { order_id: "gid://shopify/Order/123" },
          headers: { "Authorization" => "Bearer bad-token" },
          as: :json,
        )

        expect(response).to(have_http_status(:unauthorized))
        body = JSON.parse(response.body)
        expect(body["errors"]).to(include("Invalid session token"))
      end
    end
  end

  describe "OPTIONS /api/shipping_address_updates" do
    it "returns ok with CORS headers for allowed origin" do
      process(
        :options,
        "/api/shipping_address_updates",
        headers: { "Origin" => "https://extensions.shopifycdn.com" },
      )

      expect(response).to(have_http_status(:ok))
      expect(response.headers["Access-Control-Allow-Origin"]).to(eq("https://extensions.shopifycdn.com"))
      expect(response.headers["Access-Control-Allow-Headers"]).to(include("Authorization"))
    end

    it "omits CORS origin for disallowed origins" do
      process(:options, "/api/shipping_address_updates", headers: { "Origin" => "https://evil.com" })

      expect(response).to(have_http_status(:ok))
      expect(response.headers["Access-Control-Allow-Origin"]).to(be_nil)
    end
  end
end
