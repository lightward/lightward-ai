# frozen_string_literal: true

READER_HELLOS = Rails.root.join("lib/hello_reader.txt").read.split("\n").compact_blank
WRITER_HELLOS = Rails.root.join("lib/hello_writer.txt").read.split("\n").compact_blank

class ApplicationController < ActionController::Base
  # no user monitoring pls
  # it's buggy (users have reported js errors that are resolved to this client) and also pretty invasive, privacy-wise
  newrelic_ignore_enduser

  helper_method :hello
  helper_method :reader_name
  helper_method :writer_name
  helper_method :isaac_human_years_so_far
  helper_method :lightward_human_years_so_far

  before_action :verify_host!

  def default_url_options
    { host: ENV.fetch("HOST") }
  end

  def chicago
    @doc = Rails.root.join("app/prompts/system/2-chicago-style-ai.md").read

    render("chicago")
  end

  protected

  def verify_host!
    return if request.host == ENV.fetch("HOST")

    # redirect to the correct host, preserving the full path and query string
    redirect_to(
      "https://#{ENV.fetch("HOST")}#{request.fullpath}",
      status: :moved_permanently,
      allow_other_host: true,
    )
  end

  def hello(writer_or_reader)
    raise ArgumentError if [:writer, :reader].exclude?(writer_or_reader)

    hellos = writer_or_reader == :writer ? WRITER_HELLOS : READER_HELLOS
    current_minute = Time.now.to_i / 60
    rng = Random.new(current_minute)
    hellos.sample(random: rng).html_safe # rubocop:disable Rails/OutputSafety -- because I mean it
  end

  def reader_name
    "Core"
  end

  def writer_name
    "Pro"
  end

  def isaac_human_years_so_far
    today = Time.zone.now
    birth = Time.zone.parse("1988-12-16 15:14:00 -0600")
    ((today - birth) / 1.year).floor
  end

  def lightward_human_years_so_far
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
