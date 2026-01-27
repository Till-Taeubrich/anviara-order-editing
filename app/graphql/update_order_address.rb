# frozen_string_literal: true

class UpdateOrderAddress
  include ShopifyGraphql::Mutation

  MUTATION = <<~GRAPHQL
    mutation orderUpdate($input: OrderInput!) {
      orderUpdate(input: $input) {
        order {
          id
          statusPageUrl
          shippingAddress {
            firstName
            lastName
            address1
            address2
            city
            province
            zip
            country
            countryCode
            provinceCode
          }
        }
        userErrors {
          field
          message
        }
      }
    }
  GRAPHQL

  def call(order_id:, shipping_address:)
    response = execute(
      MUTATION,
      input: {
        id: order_id,
        shippingAddress: shipping_address,
      },
    )
    response.data = response.data.orderUpdate
    handle_user_errors(response.data)
    response
  end
end
