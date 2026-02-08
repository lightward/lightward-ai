# frozen_string_literal: true

# spec/requests/layout_links_spec.rb
require "rails_helper"

RSpec.describe("layout links", type: :request) do
  before do
    host! "test.host"
  end

  describe "internal <link> references" do
    it "all resolve successfully", :aggregate_failures do
      get "/"
      expect(response).to(have_http_status(:ok))

      doc = Nokogiri::HTML(response.body)
      internal_links = doc.css('link[href^="/"]')
        .map { |el| el["href"] }
        .reject { |href| href.match?(/\.(png|ico|jpg|jpeg|gif|svg|css|js|woff2?)(\?|$)/) }

      expect(internal_links).not_to(be_empty, "expected to find internal <link> references to audit")

      internal_links.each do |href|
        get href
        expect(response).not_to(
          have_http_status(:not_found),
          "expected #{href} to resolve, but got 404",
        )
      end
    end
  end
end
