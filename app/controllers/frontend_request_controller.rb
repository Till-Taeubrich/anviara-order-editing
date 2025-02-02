# frozen_string_literal: true

class FrontendRequestController < AuthenticatedController
  def create
    render json: { message: "Hello from backend" }
  end
end
