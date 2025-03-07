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

    it "recognizes a user" do
      user = User.create!(email: "foo@bar.com", google_id: "asdf")
      allow_any_instance_of(ChatsController).to(receive(:current_user).and_return(user)) # rubocop:disable RSpec/AnyInstance

      get "/"
      expect(response.body).to(include("foo@bar.com"))
    end
  end
end
