# frozen_string_literal: true

Rails.application.config.middleware.insert_before(0, Rack::Cors) do
  allow do
    origins "*"
    # Retry-After is not CORS-safelisted; expose it so cross-origin browser
    # clients can read the budget layer's pacing signal off a 429.
    resource "/api/plain", headers: :any, methods: [:post, :options], expose: ["Retry-After"]
    resource "/api/stream", headers: :any, methods: [:post, :options], expose: ["Retry-After"]
  end
end
