# frozen_string_literal: true

HELLOS = Rails.root.join("lib/hellos.txt").read.split("\n").compact_blank

class ApplicationController < ActionController::Base
  # no user monitoring pls
  # it's buggy (users have reported js errors that are resolved to this client) and also pretty invasive, privacy-wise
  newrelic_ignore_enduser

  helper_method :nows_hello

  protected

  def nows_hello
    current_minute = Time.now.to_i / 60
    rng = Random.new(current_minute)
    HELLOS.sample(random: rng)
  end
end
