# frozen_string_literal: true

Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins "*"
    resource "/api/plain", headers: :any, methods: [:post, :options]
    resource "/api/stream", headers: :any, methods: [:post, :options]
  end
end
