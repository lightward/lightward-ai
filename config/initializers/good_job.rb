# frozen_string_literal: true

# config/initializers/good_job.rb
GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(ENV.fetch("GOOD_JOB_USERNAME"), username) &&
    ActiveSupport::SecurityUtils.secure_compare(ENV.fetch("GOOD_JOB_PASSWORD"), password)
end

Rails.application.configure do
  config.good_job.execution_mode = if Rails.env.production?
    # use a standalone process in prod
    :external
  else
    # use an internal thread in dev/test
    :async
  end

  # discard jobs in production
  config.good_job.preserve_job_records = Rails.env.development?

  # fly's max is 5min; this timeout is 5s less
  config.good_job.shutdown_timeout = 295
end
