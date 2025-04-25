# frozen_string_literal: true

class ShopifySessionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    sid = request.params["session"].presence
    sid ||= env["HTTP_X_SHOPIFY_SESSION_ID"].presence
    env["shopify_session_id"] = sid if sid

    @app.call(env)
  end
end
