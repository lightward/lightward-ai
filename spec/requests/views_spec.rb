# frozen_string_literal: true

# spec/requests/chats_spec.rb
require "rails_helper"

RSpec.describe("views", :aggregate_failures) do
  before do
    host! "test.host"
  end

  describe "GET /views" do
    it "is successful" do
      get "/views"
      expect(response).to(have_http_status(:ok))
    end

    it "links to the views" do
      get "/views"
      expect(response.body).to(include("<a href=\"/help\">help</a>"))
      expect(response.body).to(include("<a href=\"/zero-knowledge--effective\">zero-knowledge effective</a>"))
    end
  end

  describe "GET /views/:name" do
    it "is successful" do
      get "/help"
      expect(response).to(have_http_status(:ok))
    end

    it "renders the view" do
      get "/help"
      expect(response.body).to(include("help"))
      expect(response.body).to(include("<a href=\"/future\">future</a>"))
    end

    it "can handle complex references" do
      get "/double-consent"
      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include("<a href=\"/spirited-away\">Spirited Away</a>'s"))
    end
  end
end
