# frozen_string_literal: true

# spec/controllers/chats_controller_spec.rb
require "rails_helper"

RSpec.describe(ViewsController, :aggregate_failures) do
  describe "GET #list" do
    it "returns a successful response" do
      get :list
      expect(response).to(have_http_status(:success))
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
  end
end
