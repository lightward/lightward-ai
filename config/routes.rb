# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"

  root "chats#index", as: :chats
  get ":chat_id", to: "chats#show", as: :chat
  post "chats/message", to: "chats#message"
  post "chats/:chat_id/message", to: "chats#message"
end
