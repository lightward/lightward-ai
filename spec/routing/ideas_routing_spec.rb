# frozen_string_literal: true

# spec/routing/ideas_routing_spec.rb
require "rails_helper"

RSpec.describe("routing ideas", :aggregate_failures) do
  it "routes GET /ideas to ideas#list" do
    expect(get: "/ideas").to(route_to(controller: "ideas", action: "list"))
  end

  it "routes GET /:name to ideas#read" do
    expect(get: "/no").to(route_to(controller: "ideas", action: "read", name: "no"))
  end

  it "does not route GET /non_existent_idea to ideas#read" do
    expect(get: "/non_existent_idea").not_to(route_to(controller: "ideas", action: "read", name: "non_existent_idea"))
  end
end
