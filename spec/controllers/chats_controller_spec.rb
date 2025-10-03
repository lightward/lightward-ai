# frozen_string_literal: true

# spec/controllers/chats_controller_spec.rb
require "rails_helper"

RSpec.describe(ChatsController, :aggregate_failures) do
  describe "GET #reader" do
    it "returns a successful response" do
      get :reader
      expect(response).to(have_http_status(:success))
    end
  end

  describe "GET #writer" do
    it "returns a successful response" do
      get :writer
      expect(response).to(have_http_status(:success))
    end
  end

  describe "chat_context helper method" do
    context "when using reader mode" do
      it "returns a hash with the correct default keys and values" do
        get :reader

        expect(assigns(:chat_context)).to(eq({ key: "reader", name: "Lightward" }))
      end
    end

    context "when using writer mode" do
      it "returns a hash with the correct default keys and values" do
        get :writer

        expect(assigns(:chat_context)).to(eq({ key: "writer", name: "Lightward Pro" }))
      end
    end
  end
end
