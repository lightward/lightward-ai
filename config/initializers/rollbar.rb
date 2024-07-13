# frozen_string_literal: true

require "rollbar/rails"

Rollbar.configure do |config|
  config.access_token = ENV.fetch("ROLLBAR_ACCESS_TOKEN", nil)

  # Disable if we don't have the config we need
  config.enabled = config.access_token.present? && !Rails.env.test?

  # Pin to the environment of choice
  config.environment = config.enabled ? ENV.fetch("ROLLBAR_ENV") : nil

  # Record the version we're running
  config.code_version = ENV["RELEASE_LABEL"].presence || "unreleased"

  config.js_enabled = config.enabled

  if config.js_enabled
    config.js_options = {
      accessToken: ENV.fetch("ROLLBAR_POST_CLIENT_ITEM_ACCESS_TOKEN"),
      captureUncaught: true,
      payload: {
        environment: config.environment,
      },
    }
  end

  # Always include a backtrace, even when reporting without a rescued exception
  config.populate_empty_backtraces = true

  # Record some Fly environment variables
  config.custom_data_method = lambda {
    # nb: there are keys that we *don't* want to log, because it's a secret - i.e. FLY_API_TOKEN
    {
      fly_app_name: ENV.fetch("FLY_APP_NAME", nil),
      fly_image_ref: ENV.fetch("FLY_IMAGE_REF", nil),
      fly_machine_id: ENV.fetch("FLY_MACHINE_ID", nil),
      fly_machine_version: ENV.fetch("FLY_MACHINE_VERSION", nil),
      fly_private_ip: ENV.fetch("FLY_PRIVATE_IP", nil),
      fly_process_group: ENV.fetch("FLY_PROCESS_GROUP", nil),
      fly_public_ip: ENV.fetch("FLY_PUBLIC_IP", nil),
      fly_region: ENV.fetch("FLY_REGION", nil),
    }
  }

  # Add exception class names to the exception_level_filters hash to
  # change the level that exception is reported at. Note that if an exception
  # has already been reported and logged the level will need to be changed
  # via the rollbar interface.
  # Valid levels: 'critical', 'error', 'warning', 'info', 'debug', 'ignore'
  # 'ignore' will cause the exception to not be reported at all.
  # config.exception_level_filters.merge!({})

  # You can also specify a callable, which will be called with the exception instance.
  # config.exception_level_filters.merge!('MyCriticalException' => lambda { |e| 'critical' })

  # Send errors to rollbar in a background thread.
  config.use_thread
end
