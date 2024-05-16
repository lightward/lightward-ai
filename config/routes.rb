Rails.application.routes.draw do
  root 'chats#index'
  post 'chats/message', to: 'chats#message'

  get "__healthcheck" => "rails/health#show", as: :rails_health_check
end
