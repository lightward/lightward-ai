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
    ["www.lightward.ai", "lightward.ai", "chat.lightward.ai", "staging.lightward.ai"].each do |host|
      host! host
      get "/"
      expect(response).to(have_http_status(301))
      expect(response).to(redirect_to("https://lightward.com/"))
    end
  end
end
