# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Root route
  root "chats#index"

  # API endpoint for sending messages to the chat
  post "chats/message", to: "chats#message"

  # Webhook endpoints
  post "webhooks/helpscout", to: "helpscout#receive"

  # Patreon auth
  get "login", to: "auth/patreon#login", as: :login
  get "auth/patreon/callback", to: "auth/patreon#callback"
  get "logout", to: "auth/patreon#logout", as: :logout
end
