# frozen_string_literal: true

# spec/requests/hosts_spec.rb
require "rails_helper"
require "webmock/rspec"

RSpec.describe("hosts", :aggregate_failures, type: :request) do
  before do
    # Stub the lightward.inc check that happens in LightwardRedirectMiddleware
    stub_request(:get, %r{https://lightward\.inc/.*})
      .to_return(status: 404)
  end

  it "accepts the primary host" do
    host! "test.host"
    get "/"
    expect(response).to(have_http_status(:ok))
  end

  it "redirects unknown hosts to the canonical host" do
    host! "unknown.host"
    get "/pro?some=params"
    expect(response).to(have_http_status(:moved_permanently))
    expect(response).to(redirect_to("https://test.host/pro?some=params"))
  end

  it "redirects www to the canonical host" do
    host! "www.test.host"
    get "/llms"
    expect(response).to(have_http_status(:moved_permanently))
    expect(response).to(redirect_to("https://test.host/llms"))
  end
end
