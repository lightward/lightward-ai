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
  get "/sitemap-ideas", to: "sitemaps#ideas", format: :xml
  get "/sitemap-views.xml", to: redirect("/sitemap-ideas.xml", status: 301)

  # ideas
  get "/ideas", to: "ideas#list", as: :ideas
  get "/views", to: redirect("/ideas", status: 301)
  get "/:name", to: "ideas#read", as: :idea, constraints: ->(req) {
    IdeasController.all_names.include?(req.params[:name])
  }
end
