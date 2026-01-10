# frozen_string_literal: true

require "rails_helper"

RSpec.describe(FulfillmentOrdersRoutingCompleteJob, type: :job) do
  it "raises when shop not found" do
    expect do
      described_class.perform_now(shop_domain: "unknown.myshopify.com", webhook: {})
    end.to(raise_error(ActiveRecord::RecordNotFound))
  end
end
