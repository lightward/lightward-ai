# frozen_string_literal: true

module Prompts
  module OpenAI
    class << self
      def model
        # just using this for everything until such time as it becomes obvious that we shouldn't
        "gpt-4o"
      end

      def api_request(payload, &block)
        uri = URI("https://api.openai.com/v1/chat/completions")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path, {
          "Content-Type": "application/json",
          "Authorization": "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
        })
        request.body = payload.to_json

        http.request(request, &block)
      end
    end
  end
end
