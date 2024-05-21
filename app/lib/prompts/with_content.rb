# frozen_string_literal: true

module Prompts
  module WithContent
    class << self
      def prepare_with_content(uri_requested)
        with_content_key = calculate_with_content_key(uri_requested)

        Rails.cache.fetch(with_content_key, expires_in: 10.minutes) do
          response = HTTParty.get(uri_requested)

          sanitized_body = Loofah.fragment(response.body).scrub!(:prune).to_html

          # assemble the response code, headers, and body into a hash
          {
            uri_requested: uri_requested,
            uri_after_any_redirects: response.request.last_uri.to_s,
            code: response.code,
            headers: response.headers,
            sanitized_body: sanitized_body,
          }
        end

        with_content_key
      end

      def get_with_content(uri_requested)
        with_content_key = calculate_with_content_key(uri_requested)

        Rails.cache.read(with_content_key)
      end

      def get_with_content_by_key(with_content_key)
        Rails.cache.read(with_content_key) || { error: "Additional context was requested, but was not found." }
      end

      def calculate_with_content_key(uri_requested)
        Digest::SHA256.hexdigest("#{uri_requested}?#{Rails.application.secret_key_base}")
      end
    end
  end
end
