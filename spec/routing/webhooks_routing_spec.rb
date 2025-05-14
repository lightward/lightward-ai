# frozen_string_literal: true

require "rails_helper"

RSpec.describe("routing webhooks", :aggregate_failures) do
  it "routes POST /webhooks/helpscout to webhooks/helpscout#receive" do
    expect(post: "/webhooks/helpscout").to(route_to(
      controller: "webhooks/helpscout", action: "receive",
    ))
  end
end
