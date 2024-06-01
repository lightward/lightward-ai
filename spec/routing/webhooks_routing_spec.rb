# frozen_string_literal: true

# spec/routing/chats_routing_spec.rb
require "rails_helper"

RSpec.describe("routing helpscout", :aggregate_failures) do
  it "routes POST /webhooks/helpscout to helpscout#receive" do
    expect(post: "/webhooks/helpscout").to(route_to(
      controller: "helpscout", action: "receive",
    ))
  end
end
