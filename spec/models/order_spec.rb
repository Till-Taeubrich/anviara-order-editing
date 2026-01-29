# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Order, type: :model) do
  let(:shop) { Shop.create!(shopify_domain: "test.myshopify.com", shopify_token: "token") }

  describe "validations" do
    it "is valid with shopify_id and shop" do
      order = Order.new(shopify_id: "gid://shopify/Order/123", shop: shop)
      expect(order).to(be_valid)
    end

    it "is invalid without shopify_id" do
      order = Order.new(shop: shop)
      expect(order).not_to(be_valid)
      expect(order.errors[:shopify_id]).to(include("can't be blank"))
    end

    it "is invalid without shop" do
      order = Order.new(shopify_id: "gid://shopify/Order/123")
      expect(order).not_to(be_valid)
      expect(order.errors[:shop]).to(include("must exist"))
    end

    it "requires unique shopify_id" do
      Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop)
      duplicate = Order.new(shopify_id: "gid://shopify/Order/123", shop: shop)
      expect(duplicate).not_to(be_valid)
      expect(duplicate.errors[:shopify_id]).to(include("has already been taken"))
    end
  end

  describe "Order::Editable" do
    let(:shop_with_settings) do
      shop = Shop.create!(shopify_domain: "editable-test.myshopify.com", shopify_token: "token")
      shop.create_settings!(hold_duration_minutes: 30)
      shop
    end

    describe "#edit_window_expired?" do
      it "returns false when order is within the edit window" do
        order = Order.create!(
          shopify_id: "gid://shopify/Order/202",
          shop: shop_with_settings,
          shopify_created_at: 10.minutes.ago,
        )
        expect(order.edit_window_expired?).to(be(false))
      end

      it "returns true when order is past the edit window" do
        order = Order.create!(
          shopify_id: "gid://shopify/Order/303",
          shop: shop_with_settings,
          shopify_created_at: 45.minutes.ago,
        )
        expect(order.edit_window_expired?).to(be(true))
      end

      it "returns true when order is exactly at the edit window boundary" do
        order = Order.create!(
          shopify_id: "gid://shopify/Order/101",
          shop: shop_with_settings,
          shopify_created_at: 30.minutes.ago,
        )
        expect(order.edit_window_expired?).to(be(true))
      end
    end

    describe "#edit_window_closes_at" do
      it "returns the time when the edit window closes" do
        created_at = Time.current
        order = Order.create!(
          shopify_id: "gid://shopify/Order/404",
          shop: shop_with_settings,
          shopify_created_at: created_at,
        )
        expect(order.edit_window_closes_at).to(be_within(1.second).of(created_at + 30.minutes))
      end

      it "respects the shop's hold_duration_minutes setting" do
        shop_with_settings.settings.update!(hold_duration_minutes: 60)
        created_at = Time.current
        order = Order.create!(
          shopify_id: "gid://shopify/Order/505",
          shop: shop_with_settings,
          shopify_created_at: created_at,
        )
        expect(order.edit_window_closes_at).to(be_within(1.second).of(created_at + 60.minutes))
      end
    end
  end

  describe "associations" do
    it "belongs to shop" do
      order = Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop)
      expect(order.shop).to(eq(shop))
    end

    it "has many fulfillment_orders" do
      order = Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop)
      fo = FulfillmentOrder.create!(
        shopify_id: "gid://shopify/FulfillmentOrder/1",
        status: "OPEN",
        shop: shop,
        order: order,
      )
      expect(order.fulfillment_orders).to(include(fo))
    end

    it "destroys fulfillment_orders when destroyed" do
      order = Order.create!(shopify_id: "gid://shopify/Order/123", shop: shop)
      FulfillmentOrder.create!(shopify_id: "gid://shopify/FulfillmentOrder/1", status: "OPEN", shop: shop, order: order)
      expect { order.destroy }.to(change(FulfillmentOrder, :count).by(-1))
    end
  end
end
