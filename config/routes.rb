# frozen_string_literal: true

Rails.application.routes.draw do
  root "chats#index"
  post "chats/message", to: "chats#message"
end
