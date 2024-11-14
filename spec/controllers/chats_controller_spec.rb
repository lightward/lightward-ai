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

  describe "POST #message" do
    let(:valid_chat_log) do
      [
        { role: "user", content: [{ type: "text", text: "Hello" }] },
        { role: "assistant", content: [{ type: "text", text: "Hi there!" }] },
      ]
    end

    let(:invalid_chat_log) { [{}] }

    let(:permitted_params) {
      valid_chat_log.map { |entry|
        ActionController::Parameters.new(entry).permit(:role, content: [:type, :text]).to_h.with_indifferent_access
      }
    }

    before do
      allow(SecureRandom).to(receive(:uuid).and_return("test-uuid"))
      allow(StreamMessagesJob).to(receive(:perform_later))
    end

    it "enqueues the StreamMessagesJob and returns a stream_id", :aggregate_failures do
      post :message, params: { chat_log: valid_chat_log }

      expect(response).to(have_http_status(:ok))
      expect(JSON.parse(response.body)).to(eq("stream_id" => "test-uuid"))

      expect(StreamMessagesJob).to(have_received(:perform_later).with("test-uuid", "reader", array_including(permitted_params[0], permitted_params[1])))
    end

    context "when the first message is 'ooo.fun' and the user is a writer" do
      let(:valid_chat_log) do
        [
          { role: "user", content: [{ type: "text", text: "ooo.fun" }] },
        ]
      end

      before do
        allow(controller).to(receive(:current_user).and_return(instance_double(User, writer?: true)))
      end

      it "uses the writer client if the user is a writer and the first message is 'ooo.fun'" do
        post :message, params: { chat_log: valid_chat_log }

        expect(StreamMessagesJob).to(have_received(:perform_later).with("test-uuid", "writer", [permitted_params[0]]))
      end
    end

    it "raises a ParameterMissing error if chat_log is invalid" do
      expect {
        post(:message, params: { chat_log: invalid_chat_log })
      }.to(raise_error(ActionController::ParameterMissing))
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
  end
end
