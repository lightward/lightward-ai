# frozen_string_literal: true

module Patreon
  class OauthError < StandardError; end

  class << self
    def client_id
      ENV.fetch("PATREON_CLIENT_ID")
    end

    def client_secret
      ENV.fetch("PATREON_CLIENT_SECRET")
    end

    def oauth_redirect_url
      Rails.application.routes.url_for(
        controller: "auth/patreon",
        action: "callback",
        host: ENV.fetch("HOST"),
        port: nil,
        protocol: "https",
      )
    end

    def oauth_url
      uri = URI.parse("https://www.patreon.com/oauth2/authorize")
      uri.query = {
        response_type: "code",
        client_id: Patreon.client_id,
        redirect_uri: oauth_redirect_url,
        scope: "identity",
      }.to_query

      uri.to_s
    end

    def oauth_callback(code:)
      response = HTTParty.post("https://www.patreon.com/api/oauth2/token", {
        body: {
          code: code,
          grant_type: "authorization_code",
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: oauth_redirect_url,
        },
      })

      if response.code != 200
        raise OauthError, "Failed to exchange code for token: #{response.inspect}"
      end

      response
    end

    def user_identity(access_token:)
      HTTParty.get("https://www.patreon.com/api/oauth2/v2/identity", {
        query: {
          include: "memberships",
          "fields[member]": "patron_status,next_charge_date",
        },
        headers: {
          "Authorization" => "Bearer #{access_token}",
        },
      })
    end

    def user_status(access_token:)
      response = user_identity(access_token: access_token)
      patron_status = response.dig("included", 0, "attributes", "patron_status")
      next_charge_date = response.dig("included", 0, "attributes", "next_charge_date")&.to_time

      {
        id: response.dig("data", "id").to_i,
        paid: patron_status == "active_patron",
        expires_at: next_charge_date,
      }
    end
  end
end
