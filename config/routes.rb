# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  get "/up", to: "rails/health#show", as: :rails_health_check

  get "/home", to: "home#index"

  resource :onboarding, only: [:show, :update], controller: :onboarding

  resources :products, only: [:index]
  resource :messages, only: :create
  resource :redirect, only: :new
  resource :settings_page, only: [:show, :update], controller: :settings_page
  resource :components_page, only: :show, controller: :components_page
  resource :redirect_page, only: :show, controller: :redirect_page
  namespace :api do
    resources :shipping_address_updates, only: :create
    match "/shipping_address_updates", to: "shipping_address_updates#options", via: :options
  end

  scope path: :api, format: :json do
    namespace :webhooks do
      post "fulfillment_orders_routing_complete", to: "fulfillment_orders_routing_complete#receive"
      post "compliance", to: "compliance#receive"
    end
  end

  resource :subscription, only: :new do
    resource :callback, only: :show, module: :subscription
  end

  mount ShopifyApp::Engine, at: "/"
end
