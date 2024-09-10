# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.5"

gem "rails", "~> 7.2.1"
gem "sprockets-rails"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "dotenv"
gem "tzinfo-data"
gem "naturally", "~> 2.2"
gem "nokogiri"
gem "httparty"
gem "reverse_markdown"
gem "loofah"
gem "pg"
gem "good_job"
gem "solid_cache"
gem "rollbar"
gem "oj" # per rollbar recommendation
gem "newrelic_rpm"
gem "slack-ruby-client"
gem "google_sign_in", "~> 1.2"

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :windows]
  gem "byebug"

  gem "factory_bot_rails"

  gem "guard", require: false
  gem "guard-rspec", require: false
  gem "guard-rubocop", require: false

  # lint
  gem "rubocop", "~> 1.66", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-shopify", require: false

  # audit
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end

group :test do
  gem "rspec"
  gem "rspec-rails", "~> 7"
  gem "rspec-github", require: false
  gem "rails-controller-testing"
  gem "webmock", "~> 3"
end
