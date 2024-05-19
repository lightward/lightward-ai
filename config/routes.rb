# frozen_string_literal: true

Rails.application.routes.draw do
  mount GoodJob::Engine => "good_job"
  root "chats#index"
  post "chats/message", to: "chats#message"
end
