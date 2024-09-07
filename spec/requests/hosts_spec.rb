# frozen_string_literal: true

# spec/requests/hosts_spec.rb
require "rails_helper"

RSpec.describe("hosts", :aggregate_failures) do
  it "accepts the primary host" do
    host! "test.host"
    get "/"
    expect(response).to(have_http_status(200))
  end

  it "rejects unknown hosts" do
    host! "unknown.host"
    get "/"
    expect(response).to(have_http_status(403))
  end

  it "accepts legacy hosts with a 200, offering a link to the primary host" do # rubocop:disable RSpec/ExampleLength
    ["www.lightward.ai", "lightward.ai", "chat.lightward.ai", "staging.lightward.ai"].each do |host|
      host! host
      get "/"
      expect(response).to(have_http_status(200))
      expect(response.body).to(include('<a href="https://test.host/">'))
    end
  end
end
