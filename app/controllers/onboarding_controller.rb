# frozen_string_literal: true

class OnboardingController < AuthenticatedController
  skip_before_action :require_onboarding

  def show
    redirect_to(root_path(**id_token_param)) if current_shop.onboarding_completed?
  end

  def update
    current_shop.complete_onboarding!
    redirect_to(root_path(**id_token_param))
  end
end
