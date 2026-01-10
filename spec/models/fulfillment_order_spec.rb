# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FulfillmentOrder, type: :model) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }
  let(:order) { Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop) }

  describe "validations" do
    it "is valid with shopify_id, status, and shop" do
      fo = FulfillmentOrder.new(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN", shop: shop)
      expect(fo).to(be_valid)
    end

    it "is valid without order (optional)" do
      fo = FulfillmentOrder.new(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN", shop: shop, order: nil)
      expect(fo).to(be_valid)
    end

    it "is invalid without shopify_id" do
      fo = FulfillmentOrder.new(status: "OPEN", shop: shop)
      expect(fo).not_to(be_valid)
      expect(fo.errors[:shopify_id]).to(include("can't be blank"))
    end

    it "is invalid without status" do
      fo = FulfillmentOrder.new(shopify_id: "gid://shopify/FulfillmentOrder/1", shop: shop)
      expect(fo).not_to(be_valid)
      expect(fo.errors[:status]).to(include("can't be blank"))
    end

    it "is invalid without shop" do
      fo = FulfillmentOrder.new(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN")
      expect(fo).not_to(be_valid)
      expect(fo.errors[:shop]).to(include("must exist"))
    end

    it "requires unique shopify_id" do
      FulfillmentOrder.create!(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN", shop: shop)
      duplicate = FulfillmentOrder.new(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN", shop: shop)
      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:shopify_id]).to(include("has already been taken"))
    end
  end

  describe "associations" do
    it "belongs to shop" do
      fo = FulfillmentOrder.create!(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN", shop: shop)
      expect(fo.shop).to(eq(shop))
    end

    it "optionally belongs to order" do
      fo = FulfillmentOrder.create!(
        shopify_id: "gid://shopify/FulfillmentOrder/1",
        status: "OPEN",
        shop: shop,
        order: order,
      )
      expect(fo.order).to(eq(order))
    end
  end
end
