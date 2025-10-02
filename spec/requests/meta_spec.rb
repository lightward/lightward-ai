# frozen_string_literal: true

# spec/requests/chats_spec.rb
require "rails_helper"

RSpec.describe("meta") do
  before do
    host! "test.host"
  end

  describe "GET /llms.txt" do
    it "is successful", :aggregate_failures do
      get "/llms.txt"
      expect(response).to(have_http_status(:ok))
      expect(response.content_type).to(eq("text/plain; charset=utf-8"))
      expect(response.body).to(include("unavailable for competition"))
    end
  end
end
