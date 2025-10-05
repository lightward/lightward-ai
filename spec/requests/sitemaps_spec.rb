# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Sitemaps", :aggregate_failures, type: :request) do
  before do
    # Set host for URL helpers
    host! "test.host"
  end

  describe "GET /sitemap.xml" do
    it "returns success" do
      get "/sitemap.xml"
      expect(response).to(have_http_status(:success))
    end

    it "returns XML content type" do
      get "/sitemap.xml"
      expect(response.content_type).to(include("application/xml"))
    end

    it "contains sitemap index structure" do
      get "/sitemap.xml"
      expect(response.body).to(include("<sitemapindex"))
      expect(response.body).to(include("sitemap-main.xml"))
      expect(response.body).to(include("sitemap-views.xml"))
    end
  end

  describe "GET /sitemap-main.xml" do
    it "returns success" do
      get "/sitemap-main.xml"
      expect(response).to(have_http_status(:success))
    end

    it "returns XML content type" do
      get "/sitemap-main.xml"
      expect(response.content_type).to(include("application/xml"))
    end

    it "contains main site URLs" do
      get "/sitemap-main.xml"
      expect(response.body).to(include("<urlset"))
      expect(response.body).to(include("http://test.host/"))
      expect(response.body).to(include("http://test.host/pro"))
      expect(response.body).to(include("http://test.host/views"))
      expect(response.body).to(include("http://test.host/views.txt"))
    end

    it "includes changefreq" do
      get "/sitemap-main.xml"
      expect(response.body).to(include("<changefreq>daily</changefreq>"))
    end
  end

  describe "GET /sitemap-views.xml" do
    it "returns success" do
      get "/sitemap-views.xml"
      expect(response).to(have_http_status(:success))
    end

    it "returns XML content type" do
      get "/sitemap-views.xml"
      expect(response.content_type).to(include("application/xml"))
    end

    it "contains view URLs" do
      get "/sitemap-views.xml"
      expect(response.body).to(include("<urlset"))

      # Should include at least one view URL (both HTML and TXT formats)
      if ViewsController.all_names.any?
        # Pick a simple view name without special characters
        simple_view = ViewsController.all_names.find { |name| name.match?(/\A[a-z0-9-]+\z/) }
        if simple_view
          expect(response.body).to(include("http://test.host/#{simple_view}"))
          expect(response.body).to(include("http://test.host/#{simple_view}.txt"))
        end
      end
    end

    it "includes proper priority and changefreq for views" do
      get "/sitemap-views.xml"
      expect(response.body).to(include("<changefreq>weekly</changefreq>"))
    end

    it "includes both HTML and TXT versions of each view" do
      get "/sitemap-views.xml"

      # Test that we have the right number of URLs (2 per view: HTML and TXT)
      url_count = response.body.scan("<loc>").length
      expected_count = ViewsController.all_names.length * 2
      expect(url_count).to(eq(expected_count))

      # Test that all .txt URLs are present
      txt_count = response.body.scan(%r{\.txt</loc>}).length
      expect(txt_count).to(eq(ViewsController.all_names.length))
    end
  end
end
