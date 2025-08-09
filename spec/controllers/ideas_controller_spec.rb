# frozen_string_literal: true

# spec/controllers/ideas_controller_spec.rb
require "rails_helper"

RSpec.describe(IdeasController, :aggregate_failures) do
  render_views

  describe "GET #list" do
    it "returns a successful response" do
      get :list
      expect(response).to(have_http_status(:success))
    end

    it "handles hyphenated idea names correctly" do
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
    let(:idea_name) { "example_idea" }
    let(:idea_content) { "This is an example idea." }

    before do
      allow(described_class).to(receive(:all)).and_return({ idea_name => idea_content })
    end

    it "returns a successful response with the correct content" do
      get :read, params: { name: idea_name }
      expect(response).to(have_http_status(:success))
      expect(assigns(:name)).to(eq(idea_name))
      expect(assigns(:content)).to(eq(idea_content))
    end

    it "raises an error if the idea is not found" do
      allow(described_class).to(receive(:all)).and_return({})

      expect {
        get(:read, params: { name: "non_existent_idea" })
      }.to(raise_error(ActionController::RoutingError, "Idea not found"))
    end

    context "with text format" do
      it "returns plaintext content for the requested idea" do
        get :read, params: { name: idea_name }, format: :text

        expect(response).to(have_http_status(:success))
        expect(response.media_type).to(eq("text/plain"))
        expect(response.body).to(eq(idea_content))
      end

      it "raises an error if the idea is not found" do
        allow(described_class).to(receive(:all)).and_return({})

        expect {
          get(:read, params: { name: "non_existent_idea" }, format: :text)
        }.to(raise_error(ActionController::RoutingError, "Idea not found"))
      end
    end

    context "with hyphenated idea names" do
      before do
        allow(described_class).to(receive(:all)).and_return({ idea_name => idea_content, "other-idea" => "Other content" })
        allow(described_class).to(receive(:all_names)).and_return([idea_name, "other-idea"])
      end

      context "with standard hyphenation" do
        let(:idea_name) { "foo-bar-baz" }
        let(:idea_content) { "Content with hyphenated name" }

        it "replaces single hyphens with spaces in the rendered output" do
          get :read, params: { name: idea_name }
          expect(response).to(have_http_status(:success))
          expect(response.body).to(include("foo bar baz"))
          expect(response.body).not_to(include("foo-bar-baz"))
        end

        it "sets the formatted name in the page title" do
          get :read, params: { name: idea_name }
          expect(response.body).to(include("<title>Lightward / foo bar baz</title>"))
        end
      end

      context "with preserved hyphenation" do
        let(:idea_name) { "foo-bar--baz" }
        let(:idea_content) { "Content with preserved hyphen" }

        it "preserves double hyphens as single hyphens in the rendered output" do
          get :read, params: { name: idea_name }
          expect(response).to(have_http_status(:success))
          expect(response.body).to(include("foo-bar baz"))
          expect(response.body).not_to(include("foo-bar--baz"))
        end

        it "sets the formatted name with preserved hyphen in the page title" do
          get :read, params: { name: idea_name }
          expect(response.body).to(include("<title>Lightward / foo-bar baz</title>"))
        end
      end
    end
  end
end
