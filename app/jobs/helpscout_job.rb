# frozen_string_literal: true

# app/jobs/helpscout_job.rb

class HelpscoutJob < ApplicationJob
  queue_with_priority PRIORITY_HELPSCOUT

  def perform(event, event_data)
  end
end
