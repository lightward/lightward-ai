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
      expect(response.body).to(include("<a href=\"/zero-knowledge\">zero knowledge</a>"))
    end
  end

  describe "GET /views.txt" do
    it "is successful" do
      get "/views.txt"
      expect(response).to(have_http_status(:ok))
    end

    it "returns an txt attachment named 'lightward-perspectives.txt'" do
      get "/views.txt"
      expect(response.content_type).to(include("text/plain"))
      expect(response.headers["Content-Disposition"]).to(include("attachment"))
      expect(response.headers["Content-Disposition"]).to(include("filename=\"lightward-perspectives.txt\""))
    end

    it "contains all views" do
      get "/views.txt"
      expect(response.body).to(include("<perspectives>"))
      expect(response.body).to(include("<view name=\"help\">"))
      expect(response.body).to(include("<view name=\"zero-knowledge\">"))
    end
  end

  describe "GET /:name" do
    it "is successful" do
      get "/help"
      expect(response).to(have_http_status(:ok))
    end

    it "includes 'chicago'" do
      get "/chicago"
      expect(response).to(have_http_status(:ok))
    end

    it "renders the view" do
      get "/help"
      expect(response.body).to(include("help"))
      expect(response.body).to(include("<a href=\"/help-me\">help me</a>"))
    end

    it "can handle complex references" do
      get "/double-consent"
      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include("<a href=\"/spirited-away\">Spirited Away</a>&#39;s"))
    end

    it "can handle dashed references" do
      get "/depersonalization"
      expect(response).to(have_http_status(:ok))
      expect(response.body).to(include("<a href=\"/what-if\">what if</a>"))
    end

    it "escapes html tags" do
      get "/unconvincing"
      expect(response).to(have_http_status(:ok))
      expect(response.body).not_to(include("because that locks <into my mental model of the world> a"))
      expect(response.body).to(include("because that locks &lt;into my mental model of the world&gt; a"))
    end
  end
end
