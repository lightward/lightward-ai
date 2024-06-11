# frozen_string_literal: true

module Auth
  class PatreonController < ApplicationController
    def login
      redirect_to(Patreon.oauth_url, allow_other_host: true)
    end

    def logout
      session.delete(:user_id)
      redirect_to(root_path)
    end

    def callback
      response = Patreon.oauth_callback(code: params[:code])
      access_token = response["access_token"]

      user_status = Patreon.user_status(access_token: access_token)

      Rails.cache.write(
        "user/#{user_status[:id]}/paid",
        user_status[:paid],
        expires_at: user_status[:expires_at],
      )

      session[:user_id] = user_status[:id]

      redirect_to(root_path)
    rescue Patreon::OauthError
      render(plain: "Failed to authenticate with Patreon! Oh no! Go back and try again?", status: :unauthorized)
    end
  end
end
