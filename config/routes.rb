# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Root route
  root "chats#index"

  # API endpoint for sending messages to the chat
  post "chats/message", to: "chats#message"

  # Webhook endpoints
  post "webhooks/helpscout", to: "helpscout#receive"
end
