# frozen_string_literal: true

require "httparty"

module Helpscout
  class ResponseError < StandardError; end

  class << self
    def webhook_secret_key
      ENV.fetch("HELPSCOUT_WEBHOOK_SECRET_KEY")
    end

    def app_id
      ENV.fetch("HELPSCOUT_APP_ID")
    end

    def app_secret
      ENV.fetch("HELPSCOUT_APP_SECRET")
    end

    def user_id
      ENV.fetch("HELPSCOUT_USER_ID").to_i
    end

    def fetch_conversation(id, with_threads: true)
      token = cached_auth_token
      url = "https://api.helpscout.net/v2/conversations/#{id}"
      url += "?embed=threads" if with_threads

      response = HTTParty.get(url, headers: {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json",
      })

      if response.code != 200
        raise ResponseError, "Failed to fetch conversation: #{response.code}\n\n#{response.body}".strip
      end

      JSON.parse(response.body)
    end

    def render_conversation_for_ai(conversation)
      conversation_for_ai = conversation.deep_dup

      conversation_for_ai.slice!(
        "id",
        "number",
        "subject",
        "threads",
        "status",
        "state",
        "subject",
        "_embedded",
      )

      conversation_for_ai["_embedded"].slice!("threads")

      # sort by createdAt, oldest to newest. helpscout does these in the other order, which isn't helpful for us.
      conversation_for_ai["_embedded"]["threads"].sort_by! { |thread| thread["createdAt"] }

      # ignore drafts
      conversation_for_ai["_embedded"]["threads"].reject! { |thread| thread["state"] == "draft" }

      # filter thread contents
      conversation_for_ai["_embedded"]["threads"].each do |thread|
        thread.slice!(
          "type",
          "status",
          "source",
          "createdBy",
          "body",
        )

        # remove photoUrl, is unused
        thread["createdBy"].except!("photoUrl")

        # remove all but the basic attachment info
        if thread.dig("_embedded", "attachments")
          thread["_embedded"]["attachments"].each do |attachment|
            attachment.slice!(
              "id",
              "filename",
              "mimeType",
            )
          end
        end

        # simplify URLs in beacon entries, because our app URLs are looooooonnnnnggggg
        if thread.dig("source", "type") == "beacon-v2"
          thread["body"].gsub!(%r{https://[^\s<]+}) do |url|
            url = url.gsub("&amp;", "&")
            uri = URI.parse(url)

            # remove embedded, hmac, host, id_token, session, and timestamp query params
            uri.query = URI.decode_www_form(uri.query || "").reject { |key, _|
              ["embedded", "hmac", "host", "id_token", "session", "timestamp"].include?(key)
            }.to_h.to_query

            uri.to_s
          rescue URI::InvalidURIError
            # if we can't parse the URL, just leave it as is
            url
          end
        end

        # convert to markdown. nb: helpscout sometimes represents stuff in markdown itself!
        raw_html = thread["body"]
        clean_html = Loofah.fragment(raw_html).scrub!(:prune).to_html
        markdown = ReverseMarkdown.convert(clean_html, unknown_tags: :bypass)

        # now that we're *definitely* in markdown, empty out image urls
        markdown.gsub!(/\!\[.*?\]\(.*?\)/, "[image]")

        thread["body"] = markdown.strip
      end

      conversation_for_ai
    end

    def conversation_concludes_with_assistant?(conversation)
      threads = conversation.dig("_embedded", "threads") || []

      # find newest thread, i.e. having the maximum createdAt
      latest_thread = threads.max_by { |thread| thread["createdAt"] }

      return false if latest_thread.nil?

      latest_thread_user_id = latest_thread.dig("createdBy", "id")
      latest_thread_user_id == user_id
    end

    # Prevents AI from closing conversations to ensure human review
    # All statuses pass through except "closed" which returns nil
    def sanitize_status(status, conversation_id:, method:)
      if status == "closed"
        Rollbar.warning("Blocked conversation closure attempt", {
          conversation_id: conversation_id,
          method: method,
          module: "Helpscout",
        })
        return
      end
      status
    end

    def update_status(conversation_id, status:)
      status = sanitize_status(status, conversation_id: conversation_id, method: __method__)
      return unless status

      token = cached_auth_token

      response = HTTParty.patch(
        "https://api.helpscout.net/v2/conversations/#{conversation_id}",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json",
        },
        body: {
          op: "replace",
          path: "/status",
          value: status,
        }.to_json,
      )

      # 204 is the expected response code, but any 2xx is fine
      if response.code < 200 || response.code >= 300
        raise ResponseError, <<~eod.strip
          Failed to update conversation status to #{status.inspect}: #{response.code}

          #{response.body}
        eod
      end
    end

    def create_note(conversation_id, body, status:)
      status = sanitize_status(status, conversation_id: conversation_id, method: __method__)

      token = cached_auth_token

      response = HTTParty.post(
        "https://api.helpscout.net/v2/conversations/#{conversation_id}/notes",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json",
        },
        body: {
          text: body,
          user: user_id,
          status: status,
        }.to_json,
      )

      if response.code != 201
        raise ResponseError, "Failed to create note: #{response.code}\n\n#{response.body}".strip
      end
    end

    def create_draft_reply(conversation_id, body, status:, customer_id:)
      status = sanitize_status(status, conversation_id: conversation_id, method: __method__)

      token = cached_auth_token

      response = HTTParty.post(
        "https://api.helpscout.net/v2/conversations/#{conversation_id}/reply",
        headers: {
          "Authorization" => "Bearer #{token}",
          "Content-Type" => "application/json",
        },
        body: {
          text: body,
          draft: true,
          user: user_id,
          status: status,
          customer: {
            id: customer_id,
          },
        }.to_json,
      )

      if response.code != 201
        raise ResponseError, "Failed to create draft reply: #{response.code}\n\n#{response.body}".strip
      end
    end

    private

    def cached_auth_token
      Rails.cache.fetch("helpscout_auth_token", expires_in: 2.hours) do
        response = HTTParty.post("https://api.helpscout.net/v2/oauth2/token", body: {
          grant_type: "client_credentials",
          client_id: app_id,
          client_secret: app_secret,
        })

        if response.code == 200
          token_data = JSON.parse(response.body)
          token_data["access_token"]
        else
          raise ResponseError, "Failed to fetch auth token: #{response.code}\n\n#{response.body}".strip
        end
      end
    end
  end
end
