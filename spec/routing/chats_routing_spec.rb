# frozen_string_literal: true

# spec/routing/chats_routing_spec.rb
require "rails_helper"

RSpec.describe("routing to chats", :aggregate_failures) do
  context "with approved hostnames" do
    it "routes to chats#with" do # rubocop:disable RSpec/ExampleLength
      expect(get: "/with/tasks.mechanic.dev/auto-tag-new-products-by-age").to(route_to(
        controller: "chats", action: "with", location: "tasks.mechanic.dev/auto-tag-new-products-by-age",
      ))
      expect(get: "/with/learn.mechanic.dev/custom-help").to(route_to(
        controller: "chats", action: "with", location: "learn.mechanic.dev/custom-help",
      ))
      expect(get: "/with/lightward.com/pricing").to(route_to(
        controller: "chats", action: "with", location: "lightward.com/pricing",
      ))
      expect(get: "/with/guncleabe.com").to(route_to(
        controller: "chats", action: "with", location: "guncleabe.com",
      ))
    end
  end

  context "with unapproved hostnames" do
    it "does not route to chats#with" do
      expect(get: "/with/unapproved.example.com/any-path").not_to(be_routable)
      expect(get: "/with/unapproved.example.com").not_to(be_routable)
    end
  end
end
