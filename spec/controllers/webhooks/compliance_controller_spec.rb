# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Webhooks::ComplianceController, type: :request) do
  include ActiveSupport::Testing::TimeHelpers

  let(:shop_domain) { "test.myshopify.com" }
  let(:shop) { Shop.create!(shopify_domain: shop_domain, shopify_token: "token") }
  let(:secret) { "test-secret" }

  before do
    allow(ShopifyApp.configuration).to(receive(:secret).and_return(secret))
    allow(ShopifyApp.configuration).to(receive(:old_secret).and_return(""))
  end

  def webhook_headers(topic:, body:)
    digest = OpenSSL::Digest.new("sha256")
    hmac = Base64.strict_encode64(OpenSSL::HMAC.digest(digest, secret, body))

    {
      "X-Shopify-Hmac-Sha256" => hmac,
      "X-Shopify-Topic" => topic,
      "X-Shopify-Shop-Domain" => shop_domain,
    }
  end

  def post_webhook(topic:, payload:)
    body = payload.to_json
    headers = webhook_headers(topic: topic, body: body)

    post(
      "/api/webhooks/compliance",
      params: body,
      headers: headers,
      env: { "CONTENT_TYPE" => "application/json" },
    )
  end

  describe "POST /api/webhooks/compliance" do
    context "with customers/data_request topic" do
      let(:payload) do
        {
          shop_id: 954_889,
          shop_domain: shop_domain,
          orders_requested: [101, 102],
          customer: { id: 191_167, email: "john@example.com" },
          data_request: { id: 9999 },
        }
      end

      it "returns no_content and logs matching order data" do
        shop # create shop
        Order.create!(shopify_id: "gid://shopify/Order/101", shop: shop)
        Order.create!(shopify_id: "gid://shopify/Order/102", shop: shop)
        allow(Rails.logger).to(receive(:info))

        post_webhook(topic: "customers/data_request", payload: payload)

        expect(response).to(have_http_status(:no_content))
        expect(Rails.logger).to(have_received(:info).with(
          %r{\[Compliance\] customers/data_request shop=#{shop_domain}.*orders_found=2},
        ))
      end

      it "returns no_content when shop not found" do
        post_webhook(topic: "customers/data_request", payload: payload)

        expect(response).to(have_http_status(:no_content))
      end
    end

    context "with customers/redact topic" do
      let(:payload) do
        {
          shop_id: 954_889,
          shop_domain: shop_domain,
          customer: { id: 191_167, email: "john@example.com" },
          orders_to_redact: [201, 202],
        }
      end

      it "destroys matching orders and returns no_content" do
        shop # create shop
        Order.create!(shopify_id: "gid://shopify/Order/201", shop: shop)
        Order.create!(shopify_id: "gid://shopify/Order/202", shop: shop)
        Order.create!(shopify_id: "gid://shopify/Order/999", shop: shop)

        expect { post_webhook(topic: "customers/redact", payload: payload) }
          .to(change(Order, :count).by(-2))

        expect(response).to(have_http_status(:no_content))
        expect(Order.exists?(shopify_id: "gid://shopify/Order/999")).to(be(true))
      end

      it "cascades destruction to fulfillment orders" do
        shop # create shop
        order = Order.create!(shopify_id: "gid://shopify/Order/201", shop: shop)
        FulfillmentOrder.create!(
          shopify_id: "gid://shopify/FulfillmentOrder/301",
          status: "OPEN",
          shop: shop,
          order: order,
        )

        expect { post_webhook(topic: "customers/redact", payload: payload) }
          .to(change(FulfillmentOrder, :count).by(-1))
      end

      it "returns no_content when shop not found" do
        post_webhook(topic: "customers/redact", payload: payload)

        expect(response).to(have_http_status(:no_content))
      end

      it "returns no_content when no matching orders exist" do
        shop # create shop

        expect { post_webhook(topic: "customers/redact", payload: payload) }
          .not_to(change(Order, :count))

        expect(response).to(have_http_status(:no_content))
      end
    end

    context "with shop/redact topic" do
      let(:payload) do
        { shop_id: 954_889, shop_domain: shop_domain }
      end

      it "returns no_content and enqueues ShopRedactJob with 48h delay" do
        freeze_time do
          post_webhook(topic: "shop/redact", payload: payload)

          expect(response).to(have_http_status(:no_content))
          expect(ShopRedactJob).to(
            have_been_enqueued
              .with(shop_domain: shop_domain, requested_at: Time.current)
              .at(48.hours.from_now),
          )
        end
      end
    end

    context "with invalid HMAC" do
      it "returns unauthorized" do
        body = { shop_id: 1 }.to_json

        post(
          "/api/webhooks/compliance",
          params: body,
          headers: {
            "X-Shopify-Hmac-Sha256" => "invalid",
            "X-Shopify-Topic" => "shop/redact",
            "X-Shopify-Shop-Domain" => shop_domain,
          },
          env: { "CONTENT_TYPE" => "application/json" },
        )

        expect(response).to(have_http_status(:unauthorized))
      end
    end
  end
end
