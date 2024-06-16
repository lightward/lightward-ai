# frozen_string_literal: true

# spec/requests/hosts_spec.rb
require "rails_helper"

RSpec.describe("hosts") do
  it "accepts the primary host" do
    host! "test.host"
    get "/"
    expect(response).to(have_http_status(200))
  end

  it "redirects unknown hosts to the configured host", :aggregate_failures do
    host! "unknown.example.com"
    get "/"
    expect(response).to(have_http_status(301))
    expect(response.headers["Location"]).to(eq("https://test.host/"))
  end
end
