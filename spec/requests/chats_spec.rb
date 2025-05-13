# frozen_string_literal: true

# spec/requests/chats_spec.rb
require "rails_helper"

RSpec.describe("chats") do
  before do
    host! "test.host"
  end

  describe "GET /" do
    it "is successful" do
      get "/"
      expect(response).to(have_http_status(:ok))
    end
  end
end
