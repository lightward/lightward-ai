# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Chat routes
  get "/", to: "chats#reader", as: :reader
  get "/pro", to: "chats#writer", as: :writer

  # API endpoint for sending messages to the chat
  post "chats/message", to: "chats#message"

  # Webhook endpoints
  post "webhooks/helpscout", to: "helpscout#receive"

  # Google auth
  get "login/create" => "sessions#create", as: :create_login
  get "logout" => "sessions#destroy", as: :logout
end
