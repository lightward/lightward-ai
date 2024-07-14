# frozen_string_literal: true

Rails.application.routes.draw do
  resources :buttons, only: [:index, :new, :create, :show, :edit, :update] do
    get :index_archived, on: :collection, path: "archived"
    post :archive, on: :member
    post :unarchive, on: :member
  end

  resource :user, path: "account", only: [:show, :update]

  mount GoodJob::Engine => "good_job"

  # Root route
  root "chats#index", as: :root
  get "", to: "chats#index", as: :chat

  # API endpoint for sending messages to the chat
  post "chats/message", to: "chats#message"

  # Webhook endpoints
  post "webhooks/helpscout", to: "helpscout#receive"

  # Google auth
  get "login" => "sessions#new", as: :login
  get "login/create" => "sessions#create", as: :create_login
  get "logout" => "sessions#destroy", as: :logout
end
