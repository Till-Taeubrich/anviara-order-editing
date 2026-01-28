# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ShopRedactJob, type: :job) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }

  describe "#perform" do
    it "destroys the shop when it has not been reinstalled" do
      shop # ensure created
      requested_at = Time.current

      expect { described_class.perform_now(shop_domain: shop.shopify_domain, requested_at: requested_at) }
        .to(change(Shop, :count).by(-1))
    end

    it "cascades destruction to associated records" do
      Order.create!(shopify_id: "gid://shopify/Order/1", shop: shop)
      Order.create!(shopify_id: "gid://shopify/Order/2", shop: shop)
      requested_at = Time.current

      expect { described_class.perform_now(shop_domain: shop.shopify_domain, requested_at: requested_at) }
        .to(change(Order, :count).by(-2))
    end

    it "skips destruction when the shop was reinstalled after the request" do
      requested_at = 1.hour.ago
      shop.update!(shopify_token: "new-token-after-reinstall")

      expect { described_class.perform_now(shop_domain: shop.shopify_domain, requested_at: requested_at) }
        .not_to(change(Shop, :count))
    end

    it "discards when the shop is not found" do
      expect { described_class.perform_now(shop_domain: "gone.myshopify.com", requested_at: Time.current) }
        .not_to(raise_error)
    end
  end
end
