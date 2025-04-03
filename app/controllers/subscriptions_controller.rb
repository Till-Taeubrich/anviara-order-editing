# frozen_string_literal: true

class SubscriptionsController < AuthenticatedController
  skip_before_action :check_subscription

  def new
    subscription = current_shop.with_shopify_session do
      ShopifyGraphql::CreateRecurringSubscription.call(
        name: 'Test plan',
        price: 10,
        return_url: subscription_callback_url,
        trial_days: 7,
        test: true,
        interval: :monthly
      ).data
    end
    fullpage_redirect_to subscription.confirmation_url
  end
end
