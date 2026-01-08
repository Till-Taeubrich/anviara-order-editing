# frozen_string_literal: true

unless Rails.env.test?
  Sentry.init do |config|
    config.dsn = "https://03af50117de4e5d8f4c5a11d95186de2@o4510518888693760.ingest.de.sentry.io/4510636860768336"
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
    config.send_default_pii = true

    # Enable sending logs to Sentry
    config.enable_logs = true
    # Patch Ruby logger to forward logs
    config.enabled_patches = [:logger]
  end
end
