# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Chat routes
  get "/", to: "chats#reader", as: :reader
  get "/pro", to: "chats#writer", as: :writer

  # API endpoint for sending messages to the chat
  post "/chats/message", to: "chats#message"

  # Webhook endpoints
  post "/webhooks/helpscout", to: "webhooks/helpscout#receive"

  # Sitemaps
  get "/sitemap", to: "sitemaps#index", format: :xml
  get "/sitemap-main", to: "sitemaps#main", format: :xml
  get "/sitemap-views", to: "sitemaps#views", format: :xml

  # views
  get "/views", to: "views#list", as: :views
  get "/:name", to: "views#read", as: :view, constraints: ->(req) {
    ViewsController.all_names.include?(req.params[:name])
  }
end
