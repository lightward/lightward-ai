Rails.application.routes.draw do
  root 'chats#index'
  post 'chats/message', to: 'chats#message'

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
