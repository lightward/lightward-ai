# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Chat routes
  get "/", to: "chats#reader", as: :reader
  get "/pro", to: "chats#writer", as: :writer

  get "/chicago", to: "application#chicago", as: :chicago

  # Subscription routes
  put "/pro/subscription", to: "subscriptions#start", as: :subscription
  get "/pro/subscription/confirm", to: "subscriptions#confirm", as: :confirm_subscription
  delete "/pro/subscription", to: "subscriptions#cancel"

  # API endpoint for sending messages to the chat
  post "/chats/message", to: "chats#message"

  # Webhook endpoints
  post "/webhooks/helpscout", to: "webhooks/helpscout#receive"
  post "/webhooks/stripe", to: "webhooks/stripe#receive"

  # Google auth
  get "/login" => redirect("/pro")
  get "/login/create" => "sessions#create", as: :create_login
  get "/logout" => "sessions#destroy", as: :logout

  # User account
  get "/you", to: "user#show", as: :user

  # Admin
  get "/admin", to: "admin#index", as: :admin

  # views
  get "/views", to: "views#list", as: :views
  get "/:name", to: "views#read", as: :view
end
