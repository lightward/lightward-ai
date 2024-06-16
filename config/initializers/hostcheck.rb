# frozen_string_literal: true

class HostcheckMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # redirect to a known host if host is unknown
    if (host = ENV.fetch("HOST", nil)) && env["HTTP_HOST"] != host
      [301, { "Location" => "https://#{host}#{env["REQUEST_URI"]}" }, []]
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.insert_before(0, HostcheckMiddleware)
