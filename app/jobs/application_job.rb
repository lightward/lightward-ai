# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  PRIORITY_STREAM_MESSAGES = 0
  PRIORITY_HELPSCOUT = 1

  before_perform :reset_prompts_in_development

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  private

  def reset_prompts_in_development
    if Rails.env.development?
      $stdout.puts "Resetting prompts... 🔄"
      Prompts.reset! if Rails.env.development?
    end
  end
end
