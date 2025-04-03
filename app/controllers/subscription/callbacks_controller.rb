# frozen_string_literal: true

module Subscription
  class CallbacksController < AuthenticatedController
    skip_before_action :check_subscription

    def show # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
      subscription_gid = "gid://shopify/AppSubscription/#{params[:charge_id]}"
      subscription = current_shop.with_shopify_session do
        ShopifyGraphql::GetAppSubscription.call(id: subscription_gid).data.subscription
      end

      if subscription.status == 'ACTIVE'
        current_shop.update!(subscription_active: true)
        flash[:notice] = 'Subscription activated'
      else
        flash[:error] = 'Subscription failed'
      end
      redirect_to home_path(**id_token_param)
    end
  end
end
