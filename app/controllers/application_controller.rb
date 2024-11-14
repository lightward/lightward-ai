# frozen_string_literal: true

HELLOS = Rails.root.join("lib/hellos.txt").read.split("\n").compact_blank

class ApplicationController < ActionController::Base
  # no user monitoring pls
  # it's buggy (users have reported js errors that are resolved to this client) and also pretty invasive, privacy-wise
  newrelic_ignore_enduser

  helper_method :nows_hello, :nows_lightward_human_years
  helper_method :current_user

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

  def nows_lightward_human_years
    today = Time.zone.now
    [
      (today - Time.zone.parse("2010-10-18")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2014-04-26")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2015-10-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2016-07-18")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2019-04-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2020-08-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2020-12-23")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2021-03-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2021-07-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2021-08-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2023-03-01")) / (365 * 24 * 60 * 60),
      (today - Time.zone.parse("2024-06-01")) / (365 * 24 * 60 * 60),
    ].sum
  end
end
