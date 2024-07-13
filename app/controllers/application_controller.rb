# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # no user monitoring pls
  # it's buggy (users have reported js errors that are resolved to this client) and also pretty invasive, privacy-wise
  newrelic_ignore_enduser

  # skipping csrf because right now we're a tiny little js app and I don't think this is needed
  skip_before_action :verify_authenticity_token

  helper_method :current_user

  protected

  def authenticate_user!
    return if current_user

    redirect_to(login_path)
  end

  def set_current_user_id!(user_id) # rubocop:disable Naming/AccessorMethodName
    cookies.encrypted.signed[:user_id] = user_id
  end

  def current_user_id
    cookies.encrypted.signed[:user_id]
  end

  def current_user
    return unless current_user_id

    @current_user ||= User.find_by(id: current_user_id)
  end
end
