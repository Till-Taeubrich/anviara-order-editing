# frozen_string_literal: true

class RedirectPageController < AuthenticatedController
  def show
    redirect_to products_path
  end
end
