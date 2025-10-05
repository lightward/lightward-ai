# frozen_string_literal: true

# spec/controllers/views_controller_spec.rb
require "rails_helper"

RSpec.describe(ViewsController, type: :controller, aggregate_failures: true) do
  render_views

  describe "GET #list" do
    it "returns a successful response" do
      get :list
      expect(response).to(have_http_status(:success))
    end

    it "handles hyphenated view names correctly" do
      allow(described_class).to(receive(:all_names)).and_return(["foo-bar", "baz-qux--quux"])
      allow(described_class).to(receive(:all)).and_return({
        "foo-bar" => "Content for foo-bar",
        "baz-qux--quux" => "Content for baz-qux--quux",
      })

      get :list

      expect(response.body).to(include("foo bar"))
      expect(response.body).to(include("baz-qux quux"))
      expect(response.body).to(include("/foo-bar"))
      expect(response.body).to(include("/baz-qux--quux"))
    end
  end

  describe "GET #read" do
    let(:view_name) { "example_view" }
    let(:view_content) { "This is an example view." }

    before do
      allow(described_class).to(receive(:all)).and_return({ view_name => view_content })
    end

    it "returns a successful response with the correct content" do
      get :read, params: { name: view_name }
      expect(response).to(have_http_status(:success))
      expect(assigns(:name)).to(eq(view_name))
      expect(assigns(:content)).to(eq(view_content))
    end

    it "raises an error if the view is not found" do
      allow(described_class).to(receive(:all)).and_return({})

      expect {
        get(:read, params: { name: "non_existent_view" })
      }.to(raise_error(ActionController::RoutingError, "View not found"))
    end

    context "with text format" do
      it "returns plaintext content for the requested view" do
        get :read, params: { name: view_name }, format: :text

        expect(response).to(have_http_status(:success))
        expect(response.media_type).to(eq("text/plain"))
        expect(response.body).to(eq(view_content))
      end

      it "raises an error if the view is not found" do
        allow(described_class).to(receive(:all)).and_return({})

        expect {
          get(:read, params: { name: "non_existent_view" }, format: :text)
        }.to(raise_error(ActionController::RoutingError, "View not found"))
      end
    end

    context "with hyphenated view names" do
      before do
        allow(described_class).to(receive(:all)).and_return({ view_name => view_content, "other-view" => "Other content" })
        allow(described_class).to(receive(:all_names)).and_return([view_name, "other-view"])
      end

      context "with standard hyphenation" do
        let(:view_name) { "foo-bar-baz" }
        let(:view_content) { "Content with hyphenated name" }

        it "replaces single hyphens with spaces in the rendered output" do
          get :read, params: { name: view_name }
          expect(response).to(have_http_status(:success))
          expect(response.body).to(include("foo bar baz"))
          expect(response.body).not_to(include("foo-bar-baz"))
        end

        it "sets the formatted name in the page title" do
          get :read, params: { name: view_name }
          expect(response.body).to(include("<title>Lightward / foo bar baz</title>"))
        end
      end

      context "with preserved hyphenation" do
        let(:view_name) { "foo-bar--baz" }
        let(:view_content) { "Content with preserved hyphen" }

        it "preserves double hyphens as single hyphens in the rendered output" do
          get :read, params: { name: view_name }
          expect(response).to(have_http_status(:success))
          expect(response.body).to(include("foo-bar baz"))
          expect(response.body).not_to(include("foo-bar--baz"))
        end

        it "sets the formatted name with preserved hyphen in the page title" do
          get :read, params: { name: view_name }
          expect(response.body).to(include("<title>Lightward / foo-bar baz</title>"))
        end
      end
    end

    context "with linkify_content and special characters" do
      it "properly URL-encodes percent signs in generated links" do
        allow(described_class).to(receive(:all)).and_return({
          "10%-revolt" => "This is the 10% revolt content",
          "other-view" => "See also: 10% revolt",
        })
        allow(described_class).to(receive(:all_names)).and_return(["10%-revolt", "other-view"])

        get :read, params: { name: "other-view" }

        expect(response).to(have_http_status(:success))
        # The link should have %25 instead of just %
        expect(response.body).to(include('href="/10%25-revolt"'))
        # The link text should still show "10% revolt"
        expect(response.body).to(include(">10% revolt</a>"))
      end

      it "properly URL-encodes multiple special characters" do
        allow(described_class).to(receive(:all)).and_return({
          "test%&space" => "Content with special chars",
          "referrer" => "See test%&space for details",
        })
        allow(described_class).to(receive(:all_names)).and_return(["test%&space", "referrer"])

        get :read, params: { name: "referrer" }

        expect(response).to(have_http_status(:success))
        # Should properly encode % (as %25) and & (HTML escaped as &amp;)
        expect(response.body).to(include('href="/test%25&amp;space"'))
      end
    end
  end
end
