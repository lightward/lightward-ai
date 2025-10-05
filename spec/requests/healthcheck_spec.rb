# frozen_string_literal: true

# spec/requests/healthcheck_spec.rb
require "rails_helper"

RSpec.describe("healthcheck", type: :request) do
  it "works on the primary host" do
    host! "test.host"
    get "/__healthcheck"
    expect(response).to(have_http_status(:ok))
  end

  it "works on unknown hosts too" do
    host! "unknown.example.com"
    get "/__healthcheck"
    expect(response).to(have_http_status(:ok))
  end
end
