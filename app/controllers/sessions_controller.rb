# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    if (user = authenticate_via_google)
      set_current_user_id!(user.id)
      redirect_to(writer_url)
    else
      redirect_to(login_url, alert: t(:login_failed))
    end
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to(:reader)
  end

  protected

  def authenticate_via_google
    # this construction (using with_indifferent_access) is because oauth2 v1
    # appears to use strings all the way down, and oauth2 v2 uses symbols within
    # the google_sign_in hash. mechanic is currently limited to v1 because of
    # github_api, and I want to use the same code for locksmith and mechanic,
    # so! here we are.
    if (google_sign_in = flash["google_sign_in"].with_indifferent_access)
      if (id_token = google_sign_in[:id_token])
        identity = GoogleSignIn::Identity.new(id_token)
        User.for_google_identity(identity)
      elsif (error = google_sign_in[:error])
        logger.error("Google authentication error: #{error}")
        nil
      end
    end
  rescue ActiveRecord::RecordInvalid
    # someone tried to get in who doesn't belong here
    nil
  end
end
