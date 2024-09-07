# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LightwardAi
  class Application < Rails::Application
    require_relative "../lib/lightward_redirect_middleware"
    config.middleware.use(LightwardRedirectMiddleware)

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(7.1)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ["assets", "tasks"])

    if (host = ENV.fetch("HOST", nil))
      config.hosts << host
    end

    # rather than tracking an additional secret, create a synthetic one out of secrets we already have. this has the
    # positive side-effect of invalidating the secret (and thereby invalidating all client cookies) whenever any of
    # these secrets changes.
    def secret_key_base
      @secret_key_base ||= begin
        digest = OpenSSL::Digest.new("sha256")
        digest << ENV.fetch("ANTHROPIC_API_KEY", "")

        digest.hexdigest
      end
    end

    # "info" includes generic and useful information about system operation, but avoids logging too much
    # information to avoid inadvertent exposure of personally identifiable information (PII). If you
    # want to log everything, set the level to "debug".
    config.log_level = ENV.fetch("LOG_LEVEL", "info")

    # Use GoodJob (i.e. postgres) for ActiveJob
    config.active_job.queue_adapter = :good_job

    # Use solid_cache (i.e. postgres again) for our ActiveSupport::Cache::Store
    config.cache_store = :solid_cache_store
  end
end
