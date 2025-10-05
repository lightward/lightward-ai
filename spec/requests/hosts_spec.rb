# frozen_string_literal: true

# spec/requests/hosts_spec.rb
require "rails_helper"

RSpec.describe("hosts", :aggregate_failures, type: :request) do
  it "accepts the primary host" do
    host! "test.host"
    get "/"
    expect(response).to(have_http_status(:ok))
  end

  it "rejects unknown hosts" do
    host! "unknown.host"
    get "/"
    expect(response).to(have_http_status(:forbidden))
  end
end
