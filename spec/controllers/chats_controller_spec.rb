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

  describe "POST #message" do
    let(:first_message) { "I'm a slow reader" }

    let(:valid_chat_log) do
      [
        { role: "user", content: [{ type: "text", text: first_message }] },
        { role: "assistant", content: [{ type: "text", text: "Hi there!" }] },
        { role: "user", content: [{ type: "text", text: "wow!" }] },
      ]
    end

    let(:invalid_chat_log) { [{}] }

    before do
      allow(SecureRandom).to(receive(:uuid).and_return("test-uuid"))
      allow(StreamMessagesJob).to(receive(:perform_later))
    end

    it "enqueues the StreamMessagesJob and returns a stream_id", :aggregate_failures do
      post :message, params: { chat_log: valid_chat_log }

      expect(response).to(have_http_status(:ok))
      expect(JSON.parse(response.body)).to(eq("stream_id" => "test-uuid"))

      permitted_params = valid_chat_log.map { |entry|
        ActionController::Parameters.new(entry).permit(:role, content: [:type, :text]).to_h.with_indifferent_access
      }

      expect(StreamMessagesJob).to(have_received(:perform_later).with("test-uuid", "reader", array_including(permitted_params[0], permitted_params[1])))
    end

    context "when in reader mode" do
      let(:first_message) { "I'm a slow reader" }

      it "uses the writer client if the user is a writer" do
        post :message, params: { chat_log: valid_chat_log }

        expect(StreamMessagesJob).to(have_received(:perform_later).with("test-uuid", "reader", anything))
      end
    end

    context "when in writer mode" do
      let(:first_message) { "I'm a slow writer" }

      context "when the user is active" do # rubocop:disable RSpec/NestedGroups
        before do
          allow(controller).to(receive(:current_user).and_return(instance_double(User, active?: true)))
        end

        it "uses the writer client" do
          post :message, params: { chat_log: valid_chat_log }

          expect(StreamMessagesJob).to(have_received(:perform_later).with("test-uuid", "writer", anything))
        end
      end

      context "when the user is not active" do # rubocop:disable RSpec/NestedGroups
        before do
          allow(controller).to(receive(:current_user).and_return(instance_double(User, active?: false)))
        end

        it "returns an error" do
          post(:message, params: { chat_log: valid_chat_log })

          expect(response).to(have_http_status(:payment_required))
          expect(response.body).to(eq("This area requires a Lightward Pro subscription! Scroll up, and click on your email address to continue. :)"))
        end
      end

      context "when the user is not logged in" do # rubocop:disable RSpec/NestedGroups
        before do
          allow(controller).to(receive(:current_user).and_return(nil))
        end

        it "returns an error" do
          post(:message, params: { chat_log: valid_chat_log })

          expect(response).to(have_http_status(:unauthorized))
          expect(response.body).to(eq("You must be logged in to use Lightward Pro. :)"))
        end
      end
    end

    context "when the user's been fucking around" do
      let(:first_message) { "I'm a slow dancer" }

      it "raises an error" do
        expect {
          post(:message, params: { chat_log: valid_chat_log })
        }.to(raise_error(ActionController::BadRequest))
      end
    end

    it "raises a parameter error if the payload is malformed" do
      expect {
        post(:message, params: { chat_log: invalid_chat_log })
      }.to(raise_error(ActionController::ParameterMissing))
    end

    describe "permitted_chat_log_params" do
      before do
        allow(controller).to(receive(:permitted_chat_log_params).and_call_original)
      end

      it "permits valid parameters" do
        valid_params = {
          chat_log: [
            { role: "user", content: [{ type: "text", text: "I'm a slow reader" }] },
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
    context "when using reader mode" do
      it "returns a hash with the correct default keys and values" do
        get :reader

        expect(assigns(:chat_context)).to(include(:localstorage_chatlog_key))
        expect(assigns(:chat_context)[:localstorage_chatlog_key]).to(eq("reader"))
      end
    end

    context "when using writer mode" do
      it "returns a hash with the correct default keys and values" do
        allow(controller).to(receive(:current_user).and_return(instance_double(User, active?: true)))

        get :writer

        expect(assigns(:chat_context)).to(include(:localstorage_chatlog_key))
        expect(assigns(:chat_context)[:localstorage_chatlog_key]).to(eq("writer"))
      end
    end
  end
end
