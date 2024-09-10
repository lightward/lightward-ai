# frozen_string_literal: true

HELLOS = Rails.root.join("lib/hellos.txt").read.split("\n").compact_blank

class ApplicationController < ActionController::Base
  # no user monitoring pls
  # it's buggy (users have reported js errors that are resolved to this client) and also pretty invasive, privacy-wise
  newrelic_ignore_enduser

  helper_method :current_user
  helper_method :nows_hello

  protected

  def authenticate_user!
    return if current_user

    redirect_to(login_path)
  end

  def set_current_user_id!(user_id)
    cookies.encrypted.signed[:user_id] = user_id
  end

  def current_user_id
    cookies.encrypted.signed[:user_id]
  end

  def current_user
    return unless current_user_id

    @current_user ||= User.find_by(id: current_user_id)
  end

  def nows_hello
    current_minute = Time.now.to_i / 60
    rng = Random.new(current_minute)
    HELLOS.sample(random: rng)
  end
end
