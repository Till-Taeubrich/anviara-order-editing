# frozen_string_literal: true

class GetFulfillmentOrder
  include ShopifyGraphql::Query

  QUERY = <<~GRAPHQL
    query fulfillmentOrder($id: ID!) {
      fulfillmentOrder(id: $id) {
        status
        createdAt
        order { id }
      }
    }
  GRAPHQL

  def call(fulfillment_order_id:)
    response = execute(QUERY, id: fulfillment_order_id)
    response.data = response.data.fulfillmentOrder
    response
  end
end
