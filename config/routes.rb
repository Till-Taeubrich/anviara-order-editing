# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  get "/up", to: "rails/health#show", as: :rails_health_check

  get "/home", to: "home#index"

  resources :products, only: [:index]
  resource :messages, only: :create
  resource :redirect, only: :new
  resource :settings_page, only: :show, controller: :settings_page
  resource :components_page, only: :show, controller: :components_page
  resource :redirect_page, only: :show, controller: :redirect_page
  resource :frontend_request, only: :create, controller: :frontend_request

  resource :subscription, only: :new do
    resource :callback, only: :show, module: :subscription
  end

  scope path: :api, format: :json do
    namespace :webhooks do
      # add webhook route here
    end
  end

  mount ShopifyApp::Engine, at: "/"
end
