# frozen_string_literal: true

class ReleaseFulfillmentOrderHold
  include ShopifyGraphql::Mutation

  MUTATION = <<~GRAPHQL
    mutation fulfillmentOrderReleaseHold($id: ID!) {
      fulfillmentOrderReleaseHold(id: $id) {
        fulfillmentOrder {
          status
        }
        userErrors { field message }
      }
    }
  GRAPHQL

  def call(fulfillment_order_id:)
    response = execute(MUTATION, id: fulfillment_order_id)
    response.data = response.data.fulfillmentOrderReleaseHold
    handle_user_errors(response.data)
    response
  end
end
