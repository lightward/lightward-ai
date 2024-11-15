# frozen_string_literal: true

# spec/controllers/chats_controller_spec.rb
require "rails_helper"

RSpec.describe(AdminController, :aggregate_failures) do
  describe "GET #index" do
    context "when the user is an admin" do
      before do
        allow(controller).to(receive(:current_user).and_return(instance_double(User, admin?: true)))
      end

      it "returns a successful response" do
        get :index
        expect(response).to(have_http_status(:success))
      end
    end

    context "when the user is not an admin" do
      before do
        allow(controller).to(receive(:current_user).and_return(instance_double(User, admin?: false)))
      end

      it "raises a bad request error" do
        expect { get(:index) }.to(raise_error(ActionController::BadRequest))
      end
    end

    context "when the user is not logged in" do
      before do
        allow(controller).to(receive(:current_user).and_return(nil))
      end

      it "renders the login template" do
        get :index
        expect(response).to(render_template("login"))
      end
    end
  end
end
