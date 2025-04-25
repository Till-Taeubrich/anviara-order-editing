# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# backend
gem "activerecord-session_store"
gem "bootsnap", require: false
gem "dotenv-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "rails", "~> 8.0.0"
gem "redis", "~> 5.0"
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# shopify
gem "polaris_view_components", "~> 2.0"
gem "shopify_app", "~> 22.5.0"
gem "shopify_graphql", "~> 2.0"

# frontend
gem "jsbundling-rails"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"

group :development, :test do
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "http_logger"
  gem "rspec-rails", github: "rspec/rspec-rails"
end

group :development do
  gem "foreman"
  gem "hotwire-livereload"
  gem "pry-rails"
  gem "rubocop-shopify", "~> 2.16"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "mocha"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webmock"
end
