# frozen_string_literal: true

module Auth
  class PatreonController < ApplicationController
    def login
      redirect_to(Patreon.oauth_url, allow_other_host: true)
    end

    def callback
      response = Patreon.oauth_callback(code: params[:code])
      access_token = response["access_token"]

      info = Patreon.user_status(access_token: access_token)

      render(json: info)
    rescue Patreon::OauthError
      render(plain: "Failed to authenticate with Patreon! Oh no! Go back and try again?", status: :unauthorized)
    end
  end
end
