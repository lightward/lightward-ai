# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # no user monitoring pls
  # it's buggy (users have reported js errors that are resolved to this client) and also pretty invasive, privacy-wise
  newrelic_ignore_enduser

  # skipping csrf because right now we're a tiny little js app and I don't think this is needed
  skip_before_action :verify_authenticity_token

  helper_method :user_paid?

  protected

  def user_paid?
    user_id = session[:user_id]

    return false unless user_id

    if @user_paid.nil?
      @user_paid = Rails.cache.fetch("user/#{user_id}/paid")
    end

    @user_paid
  end
end
