# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Chat routes
  get "/", to: "chats#reader", as: :reader
  get "/pro", to: "chats#writer", as: :writer

  get "/chicago", to: "application#chicago", as: :chicago

  # API endpoint for sending messages to the chat
  post "/chats/message", to: "chats#message"

  # Webhook endpoints
  post "/webhooks/helpscout", to: "webhooks/helpscout#receive"

  # views
  get "/views", to: "views#list", as: :views
  get "/:name", to: "views#read", as: :view, constraints: ->(req) {
    ViewsController.all_names.include?(req.params[:name])
  }
end
