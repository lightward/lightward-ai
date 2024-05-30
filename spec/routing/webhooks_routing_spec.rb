# frozen_string_literal: true

# spec/routing/chats_routing_spec.rb
require "rails_helper"

RSpec.describe("routing webhooks", :aggregate_failures) do
  it "routes POST /webhooks/helpscout to webhooks#helpscout" do
    expect(post: "/webhooks/helpscout").to(route_to(
      controller: "webhooks", action: "helpscout",
    ))
  end
end
