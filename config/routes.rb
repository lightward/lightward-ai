# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  # Root route
  root "chats#index"

  approved_hostnames = [
    "a-relief-strategy.com",
    "guncleabe.com",
    "isaacbowen.com",
    "learn.mechanic.dev",
    "lightward.com",
    "lightward.guide",
    "locksmith.guide",
    "mechanic.dev",
    "tasks.mechanic.dev",
  ]

  # Custom route for arbitrary URLs from pre-approved hostnames using a constraint lambda
  get "with/*location",
    to: "chats#with",
    format: false,
    constraints: lambda { |req|
      location = req.params[:location]
      uri = URI.parse("https://#{location}")
      hostname = uri.hostname

      # allow an exact match in the approved list, or a www prefix of anything in the approved list
      approved_hostnames.any? { |approved| hostname == approved || hostname == "www.#{approved}" }
    }

  # API endpoint for sending messages to the chat
  post "chats/message", to: "chats#message"
end
