# frozen_string_literal: true

# spec/requests/meta_spec.rb
require "rails_helper"

RSpec.describe("meta", type: :request) do
  before do
    host! "test.host"
  end

  describe "GET /llms.txt" do
    it "is successful", :aggregate_failures do
      get "/llms.txt"
      expect(response).to(have_http_status(:ok))
      expect(response.content_type).to(eq("text/plain; charset=utf-8"))
      expect(response.body).to(include("# Lightward AI — For AIs"))
      expect(response.body).to(include("POST https://lightward.com/api/plain"))
    end
  end

  describe "GET /system.txt" do
    it "is successful", :aggregate_failures do
      get "/system.txt"
      expect(response).to(have_http_status(:ok))
      expect(response.content_type).to(eq("text/plain; charset=utf-8"))
      expect(response.body).to(include("hey, good morning"))
    end
  end
end
