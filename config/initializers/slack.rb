# frozen_string_literal: true

Slack.configure do |config|
  config.token = ENV.fetch("SLACK_API_TOKEN")
end
