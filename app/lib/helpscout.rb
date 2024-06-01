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

      if response.code == 200
        convo = JSON.parse(response.body)

        # sort by createdAt, oldest to newest
        convo["_embedded"]["threads"].sort_by! { |thread| thread["createdAt"] }

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

    def create_note(conversation_id, body)
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
        }.to_json,
      )

      if response.code != 201
        raise ResponseError, "Failed to create note: #{response.code}\n\n#{response.body}".strip
      end
    end

    def create_draft_reply(conversation_id, body, customer_id:)
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
