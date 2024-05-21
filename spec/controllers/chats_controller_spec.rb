# frozen_string_literal: true

# spec/controllers/chats_controller_spec.rb
require "rails_helper"

RSpec.describe(ChatsController, :aggregate_failures) do
  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to(have_http_status(:success))
    end
  end

  describe "GET #with" do
    it "sets the correct chat context and renders the index template" do # rubocop:disable RSpec/ExampleLength
      location = "example.com"
      allow(Prompts::WithContent).to(receive(:prepare_with_content).and_return("prepared_content"))

      get :with, params: { location: location }

      expect(assigns(:chat_context)[:localstorage_chatlog_key]).to(eq("chatLogData-with-#{location}"))
      expect(assigns(:chat_context)[:with_content_key]).to(eq("prepared_content"))
      expect(response).to(render_template(:index))
    end
  end

  describe "POST #message" do
    let(:valid_chat_log) do
      [
        { role: "user", content: { type: "text", text: "Hello" } },
        { role: "assistant", content: { type: "text", text: "Hi there!" } },
      ]
    end

    let(:invalid_chat_log) { [{}] }

    before do
      allow(SecureRandom).to(receive(:uuid).and_return("test-uuid"))
      allow(StreamMessagesJob).to(receive(:perform_later))
    end

    context "with valid chat_log params" do
      it "enqueues the StreamMessagesJob and returns a stream_id", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        post :message, params: { chat_log: valid_chat_log }

        expect(response).to(have_http_status(:ok))
        expect(JSON.parse(response.body)).to(eq("stream_id" => "test-uuid"))

        permitted_params = valid_chat_log.map { |entry|
          ActionController::Parameters.new(entry).permit(:role, content: [:type, :text]).to_h.with_indifferent_access
        }

        expect(StreamMessagesJob).to(have_received(:perform_later).with("test-uuid", array_including(permitted_params[0], permitted_params[1]), nil))
      end
    end

    context "with invalid chat_log params" do
      it "raises a ParameterMissing error" do
        expect {
          post(:message, params: { chat_log: invalid_chat_log })
        }.to(raise_error(ActionController::ParameterMissing))
      end
    end

    describe "permitted_chat_log_params" do
      before do
        allow(controller).to(receive(:permitted_chat_log_params).and_call_original)
      end

      it "permits valid parameters" do # rubocop:disable RSpec/ExampleLength
        valid_params = {
          chat_log: [
            { role: "user", content: [{ type: "text", text: "Hello" }] },
            { role: "assistant", content: [{ type: "text", text: "Hi there!" }] },
          ],
        }

        post :message, params: valid_params
        valid_params[:chat_log].map(&:with_indifferent_access)
        expect(controller).to(have_received(:permitted_chat_log_params))
      end

      it "raises an error for invalid parameters" do
        invalid_params = { chat_log: [{}] }

        expect {
          post(:message, params: invalid_params)
        }.to(raise_error(ActionController::ParameterMissing))
      end
    end
  end

  describe "chat_context helper method" do
    it "returns a hash with the correct default keys and values" do
      get :index

      expect(assigns(:chat_context)).to(include(:localstorage_chatlog_key))
      expect(assigns(:chat_context)[:localstorage_chatlog_key]).to(eq("chatLogData"))
    end

    it "knows about #with" do
      stub_request(:any, "https://example.com")

      get :with, params: { location: "example.com" }

      expect(assigns(:chat_context)[:localstorage_chatlog_key]).to(eq("chatLogData-with-example.com"))
    end
  end
end
