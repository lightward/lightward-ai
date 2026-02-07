# frozen_string_literal: true

# spec/requests/chats_spec.rb
require "rails_helper"

RSpec.describe("views", :aggregate_failures, type: :request) do
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

    it "links to github" do
      get "/views"
      expect(response.body).to(include("https://github.com/lightward/lightward-ai"))
    end
  end

  describe "GET /views.txt" do
    it "is successful" do
      get "/views.txt"
      expect(response).to(have_http_status(:ok))
    end

    it "returns an txt attachment named '3-perspectives.txt'" do
      ENV["RELEASE_LABEL"] = "test"

      get "/views.txt"
      expect(response.content_type).to(include("text/plain"))
      expect(response.headers["Content-Disposition"]).to(include("attachment"))
      expect(response.headers["Content-Disposition"]).to(include("filename=\"3-perspectives_test.txt\""))
    end

    it "contains all views" do
      get "/views.txt"
      expect(response.body).to(include("<system>"))
      expect(response.body).to(include("<file name=\"3-perspectives/help\">"))
      expect(response.body).to(include("<file name=\"3-perspectives/zero-knowledge\">"))
    end

    it "is, line for line, taken from the system prompt" do
      get "/views.txt"

      # Generate the full system prompt XML
      system_messages = Prompts.build_system_prompt
      system_prompt_xml = system_messages.drop(1).pluck(:text).join

      # Check each line from views.txt exists in the system prompt
      count = 0
      response.body.each_line do |line|
        line_content = line.strip

        expect(system_prompt_xml).to(
          include(line_content),
          "Content not found in system prompt: #{line_content}",
        )

        count += 1
      end

      # Ensure we have at least one line in the response
      expect(count).to(be > 0, "No lines found in the response body")
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

    it "includes 'for'" do
      get "/for"
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
