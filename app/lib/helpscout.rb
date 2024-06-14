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

    def fetch_conversation(id, with_threads: true, convert_threads_to_markdown: true)
      token = cached_auth_token
      url = "https://api.helpscout.net/v2/conversations/#{id}"
      url += "?embed=threads" if with_threads

      response = HTTParty.get(url, headers: {
        "Authorization" => "Bearer #{token}",
        "Content-Type" => "application/json",
      })

      if response.code == 200
        convo = JSON.parse(response.body)

        # sort by createdAt, oldest to newest. helpscout does these in the other order, which isn't helpful for us.
        convo["_embedded"]["threads"].sort_by! { |thread| thread["createdAt"] }

        # ignore drafts
        convo["_embedded"]["threads"].reject! { |thread| thread["state"] == "draft" }

        if convert_threads_to_markdown
          convo["_embedded"]["threads"].each do |thread|
            raw_html = thread["body"]
            clean_html = Loofah.fragment(raw_html).scrub!(:prune).to_html
            markdown = ReverseMarkdown.convert(clean_html, unknown_tags: :bypass)

            thread["body"] = markdown
          end
        end

        convo
      else
        raise ResponseError, "Failed to fetch conversation: #{response.code}\n\n#{response.body}".strip
      end
    end

    def conversation_concludes_with_assistant?(conversation)
      threads = conversation.dig("_embedded", "threads") || []

      # find newest thread, i.e. having the maximum createdAt
      latest_thread = threads.max_by { |thread| thread["createdAt"] }

      return false if latest_thread.nil?

      latest_thread_user_id = latest_thread.dig("createdBy", "id")
      latest_thread_user_id == user_id
    end

    def update_status(conversation_id, status:)
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
