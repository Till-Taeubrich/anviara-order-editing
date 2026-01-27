# frozen_string_literal: true

module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_cors_headers
    before_action :verify_session_token

    rescue_from ActiveRecord::RecordNotFound do
      render(json: { success: false, errors: ["Record not found"] }, status: :not_found)
    end

    private

    def set_cors_headers
      origin = request.headers["Origin"]
      response.headers["Access-Control-Allow-Origin"] = origin if origin&.match?(%r{\Ahttps://extensions\.shopifycdn\.com}i)
      response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
    end

    def verify_session_token
      token = request.headers["Authorization"]&.remove("Bearer ")
      return render_unauthorized("Missing session token") if token.blank?

      jwt_payload = ShopifyAPI::Auth::JwtPayload.new(token)
      @current_shop = Shop.find_by!(shopify_domain: jwt_payload.shopify_domain)
    rescue ShopifyAPI::Errors::InvalidJwtTokenError, ActiveRecord::RecordNotFound => e
      Rails.logger.warn("JWT verification failed: #{e.message}")
      render_unauthorized("Invalid session token")
    end

    def render_unauthorized(message)
      render(json: { success: false, errors: [message] }, status: :unauthorized)
    end
  end
end
