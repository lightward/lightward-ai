# frozen_string_literal: true

Rails.application.routes.draw do
  get "/llms", to: "meta#llms", format: :txt
  get "/system", to: "meta#system", format: :txt

  # Chat routes
  get "/", to: "chats#reader", as: :reader
  get "/pro", to: "chats#writer", as: :writer

  # API endpoints
  post "/api/stream", to: "api#stream"
  post "/api/plain", to: "api#plain"

  # Sitemaps
  get "/sitemap", to: "sitemaps#index", format: :xml
  get "/sitemap-main", to: "sitemaps#main", format: :xml
  get "/sitemap-views", to: "sitemaps#views", format: :xml

  # Views
  get "/views", to: "views#list", as: :views, format: [:html, :txt]
  get "/:name", to: "views#read", as: :view, constraints: ->(req) {
    ViewsController.all_names.include?(req.params[:name])
  }
end
