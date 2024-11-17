# frozen_string_literal: true

class ScanUsersJob < ApplicationJob
  queue_with_priority PRIORITY_SCAN_USERS

  def perform
    # scan all users, check subscription status, suspend as warranted
  end
end
