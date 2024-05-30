# frozen_string_literal: true

module Helpscout
  class << self
    def webhook_secret_key
      ENV.fetch("HELPSCOUT_WEBHOOK_SECRET_KEY")
    end
  end
end
