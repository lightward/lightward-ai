# frozen_string_literal: true

# config/initializers/good_job.rb
GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(ENV.fetch("GOOD_JOB_USERNAME"), username) &&
    ActiveSupport::SecurityUtils.secure_compare(ENV.fetch("GOOD_JOB_PASSWORD"), password)
end

Rails.application.configure do
  # always use an external process - "in dev as it is in prod"
  config.good_job.execution_mode = :external

  # *only* preserve job records if configured in the env
  config.good_job.preserve_job_records = ENV["GOOD_JOB_PRESERVE_JOB_RECORDS"].present?

  # fly's max is 5min; this timeout is 5s less
  config.good_job.shutdown_timeout = 295
end
