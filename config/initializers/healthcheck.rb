# frozen_string_literal: true

class HealthcheckMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/__healthcheck"
      [200, { "Content-Type" => "text/plain" }, ["OK"]]
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.insert_before(0, HealthcheckMiddleware)
