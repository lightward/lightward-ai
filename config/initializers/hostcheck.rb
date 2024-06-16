# frozen_string_literal: true

class HostcheckMiddleware
  HOST = ENV.fetch("HOST")

  def initialize(app)
    @app = app
  end

  def call(env)
    # redirect to a known host if host is unknown
    if Rails.application.config.hosts.exclude?(env["HTTP_HOST"])
      [301, { "Location" => "https://#{HOST}#{env["REQUEST_URI"]}" }, []]
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.insert_before(0, HostcheckMiddleware)
