# frozen_string_literal: true

# spec/routing/auth_routing_spec.rb
require "rails_helper"

RSpec.describe("routing auth", :aggregate_failures) do
  it "routes GET /login/create to sessions#create" do
    expect(get: "/login/create").to(route_to(controller: "sessions", action: "create"))
  end

  it "routes GET /logout to sessions#destroy" do
    expect(get: "/logout").to(route_to(controller: "sessions", action: "destroy"))
  end
end
