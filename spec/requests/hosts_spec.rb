# frozen_string_literal: true

# spec/requests/hosts_spec.rb
require "rails_helper"

RSpec.describe("hosts", :aggregate_failures) do
  it "accepts the primary host" do
    host! "test.host"
    get "/"
    expect(response).to(have_http_status(200))
  end

  it "rejects unknown hosts" do
    host! "unknown.host"
    get "/"
    expect(response).to(have_http_status(403))
  end

  it "redirects legacy hosts with a permanent redirect" do # rubocop:disable RSpec/ExampleLength
    ENV["HOST"] = "lightward.com"

    number_of_hosts_to_expect = 4
    number_of_hosts = 0

    ["www.lightward.ai", "lightward.ai", "chat.lightward.ai", "staging.lightward.ai"].each do |host|
      number_of_hosts += 1

      host! host
      get "/"
      expect(response).to(have_http_status(301))
      expect(response).to(redirect_to("https://lightward.com/"))
    end

    expect(number_of_hosts).to(eq(number_of_hosts_to_expect))
  end
end
