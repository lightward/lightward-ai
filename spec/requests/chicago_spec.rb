# frozen_string_literal: true

# spec/requests/chats_spec.rb
require "rails_helper"

RSpec.describe("chicago") do
  before do
    host! "test.host"
  end

  describe "GET /chicago" do
    it "is successful" do
      get "/chicago"
      expect(response).to(have_http_status(200))
    end

    it "contains text we recognize" do
      get "/chicago"
      expect(response.body).to(include("# chicago-style ai"))
    end
  end
end
