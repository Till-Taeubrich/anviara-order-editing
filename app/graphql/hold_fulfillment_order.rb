# frozen_string_literal: true

class HoldFulfillmentOrder
  include ShopifyGraphql::Mutation

  MUTATION = <<~GRAPHQL
    mutation fulfillmentOrderHold($id: ID!, $fulfillmentHold: FulfillmentOrderHoldInput!) {
      fulfillmentOrderHold(id: $id, fulfillmentHold: $fulfillmentHold) {
        fulfillmentOrder {
          status
          createdAt
          order { id }
        }
        userErrors { field message }
      }
    }
  GRAPHQL

  def call(fulfillment_order_id:)
    response = execute(
      MUTATION,
      id: fulfillment_order_id,
      fulfillmentHold: {
        reason: "OTHER",
        reasonNotes: "Held for order editing window",
        notifyMerchant: false,
        handle: "order-editing-window",
      },
    )
    response.data = response.data.fulfillmentOrderHold
    handle_user_errors(response.data)
    response
  end
end
