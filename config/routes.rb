# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Root route
  root "chats#index"

  # Custom route for arbitrary URLs from pre-approved hostnames using a constraint lambda
  get "with/*location",
    to: "chats#with",
    format: false,
    constraints: ->(req) { Prompts::WithContent.route_constraint(req) }

  # API endpoint for sending messages to the chat
  post "chats/message", to: "chats#message"

  # Webhook endpoints
  post "webhooks/helpscout", to: "webhooks#helpscout"
end
