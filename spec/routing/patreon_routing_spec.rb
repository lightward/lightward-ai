# frozen_string_literal: true

# spec/routing/patreon_routing_spec.rb
require "rails_helper"

RSpec.describe("Patreon Routes") do
  it "routes GET /login to auth/patreon#login" do
    expect(get: "/login").to(route_to(controller: "auth/patreon", action: "login"))
  end

  it "routes GET /auth/patreon/callback to auth/patreon#callback" do
    expect(get: "/auth/patreon/callback").to(route_to(controller: "auth/patreon", action: "callback"))
  end

  it "routes GET /logout to auth/patreon#logout" do
    expect(get: "/logout").to(route_to(controller: "auth/patreon", action: "logout"))
  end
end
