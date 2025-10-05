# frozen_string_literal: true

# spec/routing/views_routing_spec.rb
require "rails_helper"

RSpec.describe("routing views", :aggregate_failures, type: :routing) do
  it "routes GET /views to views#list" do
    expect(get: "/views").to(route_to(controller: "views", action: "list"))
  end

  it "routes GET /:name to views#read" do
    expect(get: "/no").to(route_to(controller: "views", action: "read", name: "no"))
  end

  it "does not route GET /non_existent_view to views#read" do
    expect(get: "/non_existent_view").not_to(route_to(controller: "views", action: "read", name: "non_existent_view"))
  end
end
